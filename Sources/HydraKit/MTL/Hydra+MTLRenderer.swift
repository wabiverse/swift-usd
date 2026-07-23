/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
import OpenUSDKit
#if canImport(Metal)
import Metal
import MetalKit

public extension Hydra
{
  class MTLRenderer: NSObject, MTKViewDelegate
  {
    private let device: MTLDevice
    private var hydra: Hydra.RenderEngine?

    private var pipelineState: MTLRenderPipelineState?
    private var outlinePipelineState: MTLRenderPipelineState?
    private var selectionReadPipelineState: MTLComputePipelineState?
    private var jfaMaskPipelineState: MTLComputePipelineState?
    private var jfaDilatePipelineState: MTLComputePipelineState?
    private var jfaErodePipelineState: MTLComputePipelineState?
    private var jfaSeedPipelineState: MTLComputePipelineState?
    private var jfaStepPipelineState: MTLComputePipelineState?
    private var jfaLabelPipelineState: MTLComputePipelineState?
    private var jfaLabelFillPipelineState: MTLComputePipelineState?
    private var jfaLabelSeedPipelineState: MTLComputePipelineState?
    private var commandQueue: MTLCommandQueue?

    /// Ping-pong render targets for the jump-flood outline distance field, sized
    /// to the id AOVs. Reallocated when the drawable size changes.
    private var jfaSeedTextures: [MTLTexture] = []
    /// Ping-pong single-channel masks for the majority-coverage silhouette and
    /// its morphological close, before it is seeded into the distance field.
    private var jfaMaskTextures: [MTLTexture] = []
    /// Ping-pong per-pixel model-label targets used by the select-all path to tell
    /// objects apart (raw labels, then hole-filled).
    private var jfaLabelTextures: [MTLTexture] = []
    /// GPU copy of the model-pick id table, rebuilt only when it changes, plus a
    /// one-int dummy bound for id-pair picks (the kernel binds buffer(1) but does
    /// not read it there).
    private var selectionGroupBuffer: MTLBuffer?
    private var selectionGroupBufferVersion = -1
    private var emptyGroupBuffer: MTLBuffer?
    /// GPU copy of the primId -> model-id table for select-all, rebuilt only when
    /// it changes.
    private var selectionModelBuffer: MTLBuffer?
    private var selectionModelBufferVersion = -1

    private var inFlightSemaphore = DispatchSemaphore(value: 1)

    /// Matches `OutlineUniforms` in BlitShaders.metal:
    /// five `Int32`s, three `Int32`s of padding, then a
    /// 16-byte-aligned float4.
    private struct OutlineUniforms
    {
      var selectedPrimId: Int32
      var selectedInstanceId: Int32
      var outlineWidth: Int32
      var useGroup: Int32 = 0
      var groupCount: Int32 = 0
      var selectAll: Int32 = 0
      var modelCount: Int32 = 0
      var pad2: Int32 = 0
      var outlineColor: SIMD4<Float>
    }

    convenience init(hydra: Hydra.RenderEngine)
    {
      self.init(device: hydra.hydraDevice)!
      self.hydra = hydra
    }

    init?(device: MTLDevice)
    {
      self.device = device

      super.init()

      setupPipeline()
    }

    private func setupPipeline()
    {
      commandQueue = device.makeCommandQueue()

      do
      {
        let defaultLibrary = try device.makeDefaultLibrary(bundle: .hydraKit)

        guard let vertexFunction = defaultLibrary.makeFunction(name: "vtxBlit")
        else { Msg.logger.error("HYDRA: Failed to create vertex function."); return }

        guard let fragmentFunction = defaultLibrary.makeFunction(name: "fragBlitLinear")
        else { Msg.logger.error("HYDRA: Failed to create fragment function."); return }

        // set up the pipeline state descriptor.
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.rasterSampleCount = 1
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.depthAttachmentPixelFormat = .invalid

        // configure the color attachment for blending.
        if let colorAttachment = pipelineStateDescriptor.colorAttachments[0]
        {
          colorAttachment.pixelFormat = .bgra8Unorm
          colorAttachment.isBlendingEnabled = true
          colorAttachment.rgbBlendOperation = .add
          colorAttachment.alphaBlendOperation = .add
          colorAttachment.sourceRGBBlendFactor = .one
          colorAttachment.sourceAlphaBlendFactor = .one
          colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
          colorAttachment.destinationAlphaBlendFactor = .zero
        }

        // create the pipeline state object.
        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        // a second pipeline, identical but for the fragment function,
        // that draws the custom selection outline over the composited
        // color.
        if let outlineFragment = defaultLibrary.makeFunction(name: "fragSelectionOutline")
        {
          pipelineStateDescriptor.fragmentFunction = outlineFragment
          outlinePipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }

        // reads sample 0 of the MSAA id AOVs at the click texel for the outline.
        if let readFunction = defaultLibrary.makeFunction(name: "readSelectionId")
        {
          selectionReadPipelineState = try device.makeComputePipelineState(function: readFunction)
        }

        // jump-flood passes that build the outline distance field: clean the id
        // AOVs into a solid mask (majority + morphological close), seed it, then
        // propagate nearest-silhouette coordinates.
        if let maskFunction = defaultLibrary.makeFunction(name: "jfaMask")
        {
          jfaMaskPipelineState = try device.makeComputePipelineState(function: maskFunction)
        }
        if let dilateFunction = defaultLibrary.makeFunction(name: "jfaDilate")
        {
          jfaDilatePipelineState = try device.makeComputePipelineState(function: dilateFunction)
        }
        if let erodeFunction = defaultLibrary.makeFunction(name: "jfaErode")
        {
          jfaErodePipelineState = try device.makeComputePipelineState(function: erodeFunction)
        }
        if let seedFunction = defaultLibrary.makeFunction(name: "jfaSeed")
        {
          jfaSeedPipelineState = try device.makeComputePipelineState(function: seedFunction)
        }
        if let stepFunction = defaultLibrary.makeFunction(name: "jfaStep")
        {
          jfaStepPipelineState = try device.makeComputePipelineState(function: stepFunction)
        }

        // select-all: per-object labeling, hole fill, and inter-object edge seed.
        if let labelFunction = defaultLibrary.makeFunction(name: "jfaLabel")
        {
          jfaLabelPipelineState = try device.makeComputePipelineState(function: labelFunction)
        }
        if let labelFillFunction = defaultLibrary.makeFunction(name: "jfaLabelFill")
        {
          jfaLabelFillPipelineState = try device.makeComputePipelineState(function: labelFillFunction)
        }
        if let labelSeedFunction = defaultLibrary.makeFunction(name: "jfaLabelSeed")
        {
          jfaLabelSeedPipelineState = try device.makeComputePipelineState(function: labelSeedFunction)
        }
      }
      catch
      {
        Msg.logger.error("HYDRA: Failed to create pipeline state: \(error.localizedDescription)")
      }
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
      if size.width == 0 || size.height == 0
      {
        view.drawableSize = CGSize(width: 400, height: 300)
      }
    }

    public func draw(in view: MTKView)
    {
      let semaphore = inFlightSemaphore
      semaphore.wait()

      guard view.drawableSize.width > 0, view.drawableSize.height > 0
      else { semaphore.signal(); return }

      // drawFrame gets a fresh drawable after hgi commits,
      // at the engine's current timecode (the stage's start
      // frame by default, settable for scrubbing or playback).
      drawFrame(in: view, timeCode: hydra?.currentTimeCode ?? 0.0)
    }

    /// draw the scene, and blit the result to the view.
    @MainActor @discardableResult
    func drawFrame(in view: MTKView, timeCode: Double) -> Bool
    {
      let deltaTime = 1.0 / Double(view.preferredFramesPerSecond)
      hydra?.frameDelegate?.hydraWillPull(deltaTime: deltaTime)
      defer { hydra?.frameDelegate?.hydraDidPull() }
      
      #if canImport(Hgi)
      guard let hgi = hydra?.getHgi()
      else { inFlightSemaphore.signal(); return false }
      #else
      // apple/swiftusd's hgi types are value types:
      // https://github.com/apple/SwiftUsd/issues/27
      guard var hgi = hydra?.getHgi()
      else { inFlightSemaphore.signal(); return false }
      #endif

      hgi.StartFrame()

      let viewSize = view.drawableSize
      guard
        let hgiTexture = hydra?.render(at: timeCode, viewSize: viewSize),
        let metalTexture = hgiTexture.asMetalTexture
      else { inFlightSemaphore.signal(); return false }

      // let hgi finish completely before we touch the drawable
      hgi.CommitPrimaryCommandBuffer()
      hgi.EndFrame()

      // the id AOVs are rendered and resolved now (after EndFrame),
      // so fulfill a click that is waiting to know which prim and
      // instance is under it.
      if let pending = hydra?.pendingSelection
      {
        resolveSelection(viewPoint: pending.point, viewSize: pending.viewSize, drawableSize: viewSize)
        hydra?.pendingSelection = nil
      }

      // get a fresh drawable only after hgi is done
      guard
        let drawable = view.currentDrawable,
        let blitCommandBuffer = commandQueue?.makeCommandBuffer()
      else { inFlightSemaphore.signal(); return false }

      // signal via command buffer completion, not presented handler
      let semaphore = inFlightSemaphore
      blitCommandBuffer.addCompletedHandler { _ in
        semaphore.signal()
      }

      blitToView(view, drawable: drawable, commandBuffer: blitCommandBuffer, texture: metalTexture)
      blitCommandBuffer.commit()

      return true
    }

    /// copies the texture to the view with a shader.
    @MainActor
    public func blitToView(_ view: MTKView, drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer, texture: MTLTexture)
    {
      // build the jump-flood outline field first: compute and render work cannot
      // share an encoder, so this runs its own compute encoders on the same command
      // buffer before the blit render pass opens.
      var outlineSeedTexture: MTLTexture?
      var outlineUniforms = OutlineUniforms(selectedPrimId: -1, selectedInstanceId: -1,
                                            outlineWidth: 0,
                                            outlineColor: SIMD4<Float>(repeating: 0))
      if let hydra,
         (hydra.selectedPrimId >= 0 || hydra.selectionUsesGroup || hydra.selectionSelectAll),
         let primHgi = hydra.aovTexture(.primId),
         let instHgi = hydra.aovTexture(.instanceId),
         let depthHgi = hydra.aovTexture(.depth),
         let primTex = primHgi.asMetalTexture,
         let instTex = instHgi.asMetalTexture,
         let depthTex = depthHgi.asMetalTexture
      {
        let c = hydra.selectionOutlineColor
        outlineUniforms = OutlineUniforms(selectedPrimId: hydra.selectedPrimId,
                                          selectedInstanceId: hydra.selectedInstanceId,
                                          outlineWidth: hydra.selectionOutlineWidth,
                                          useGroup: hydra.selectionUsesGroup ? 1 : 0,
                                          groupCount: Int32(hydra.selectionGroup.count),
                                          selectAll: hydra.selectionSelectAll ? 1 : 0,
                                          modelCount: Int32(hydra.selectionModelLUT.count),
                                          outlineColor: SIMD4<Float>(Float(c[0]), Float(c[1]),
                                                                     Float(c[2]), Float(c[3])))
        outlineSeedTexture = computeOutlineField(commandBuffer: commandBuffer,
                                                 primTex: primTex, instTex: instTex,
                                                 depthTex: depthTex,
                                                 groupBuffer: groupBuffer(for: hydra),
                                                 modelBuffer: modelBuffer(for: hydra),
                                                 uniforms: &outlineUniforms)
      }

      // build render pass from the captured drawable directly,
      // never touch view.currentRenderPassDescriptor or view.currentDrawable again
      let renderPassDescriptor = MTLRenderPassDescriptor()
      renderPassDescriptor.colorAttachments[0].texture = drawable.texture
      renderPassDescriptor.colorAttachments[0].loadAction = .clear
      renderPassDescriptor.colorAttachments[0].storeAction = .store
      renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

      guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
      else { Msg.logger.error("HYDRA: Failed to create a render command encoder to blit the texture to the view."); return }

      renderEncoder.pushDebugGroup("FinalBlit")
      renderEncoder.setFragmentTexture(texture, index: 0)

      if let outlinePipelineState, let outlineSeedTexture
      {
        renderEncoder.setFragmentTexture(outlineSeedTexture, index: 1)
        renderEncoder.setFragmentBytes(&outlineUniforms,
                                       length: MemoryLayout<OutlineUniforms>.stride,
                                       index: 0)
        renderEncoder.setRenderPipelineState(outlinePipelineState)
      }
      else if let pipelineState
      {
        renderEncoder.setRenderPipelineState(pipelineState)
      }

      renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
      renderEncoder.popDebugGroup()
      renderEncoder.endEncoding()

      #if os(macOS)
        commandBuffer.present(drawable, afterMinimumDuration: 1.0 / Double(view.preferredFramesPerSecond))
      #else // !os(macOS)
        commandBuffer.present(drawable, atTime: 1.0 / Double(view.preferredFramesPerSecond))
      #endif // os(macOS)
    }

    /// (Re)allocates the ping-pong jump-flood targets to match the id AOVs. The field stores
    /// a nearest-seed coordinate per texel, so it is a two-channel float target read and written
    /// by the flood passes.
    private func ensureJFATextures(width: Int, height: Int)
    {
      if jfaSeedTextures.count == 2, jfaMaskTextures.count == 2, jfaLabelTextures.count == 2,
         jfaSeedTextures[0].width == width,
         jfaSeedTextures[0].height == height
      { return }

      let seedDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rg32Float,
                                                              width: width, height: height,
                                                              mipmapped: false)
      seedDesc.usage = [.shaderRead, .shaderWrite]
      seedDesc.storageMode = .private

      let maskDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm,
                                                              width: width, height: height,
                                                              mipmapped: false)
      maskDesc.usage = [.shaderRead, .shaderWrite]
      maskDesc.storageMode = .private

      let labelDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Sint,
                                                               width: width, height: height,
                                                               mipmapped: false)
      labelDesc.usage = [.shaderRead, .shaderWrite]
      labelDesc.storageMode = .private

      jfaSeedTextures = []
      jfaMaskTextures = []
      jfaLabelTextures = []
      if let a = device.makeTexture(descriptor: seedDesc),
         let b = device.makeTexture(descriptor: seedDesc),
         let m0 = device.makeTexture(descriptor: maskDesc),
         let m1 = device.makeTexture(descriptor: maskDesc),
         let l0 = device.makeTexture(descriptor: labelDesc),
         let l1 = device.makeTexture(descriptor: labelDesc)
      {
        jfaSeedTextures = [a, b]
        jfaMaskTextures = [m0, m1]
        jfaLabelTextures = [l0, l1]
      }
    }

    /// GPU copy of the model-pick id table, rebuilt only when the selection
    /// changes. A one-int dummy is returned for id-pair picks so the mask
    /// kernel always has a buffer bound at index 1 even though it never
    /// actually reads it there.
    private func groupBuffer(for hydra: Hydra.RenderEngine) -> MTLBuffer?
    {
      if hydra.selectionUsesGroup, !hydra.selectionGroup.isEmpty
      {
        if selectionGroupBufferVersion != hydra.selectionGroupVersion
        {
          selectionGroupBuffer = hydra.selectionGroup.withUnsafeBytes {
            device.makeBuffer(bytes: $0.baseAddress!, length: $0.count,
                              options: .storageModeShared)
          }
          selectionGroupBufferVersion = hydra.selectionGroupVersion
        }
        return selectionGroupBuffer
      }

      if emptyGroupBuffer == nil
      {
        emptyGroupBuffer = device.makeBuffer(length: MemoryLayout<Int32>.stride,
                                             options: .storageModeShared)
      }
      return emptyGroupBuffer
    }

    /// GPU copy of the select-all primId -> model-id table, rebuilt only when it
    /// changes, a one-int dummy stands in when the table is empty.
    private func modelBuffer(for hydra: Hydra.RenderEngine) -> MTLBuffer?
    {
      if !hydra.selectionModelLUT.isEmpty
      {
        if selectionModelBufferVersion != hydra.selectionModelLUTVersion
        {
          selectionModelBuffer = hydra.selectionModelLUT.withUnsafeBytes {
            device.makeBuffer(bytes: $0.baseAddress!, length: $0.count,
                              options: .storageModeShared)
          }
          selectionModelBufferVersion = hydra.selectionModelLUTVersion
        }
        return selectionModelBuffer
      }

      if emptyGroupBuffer == nil
      {
        emptyGroupBuffer = device.makeBuffer(length: MemoryLayout<Int32>.stride,
                                             options: .storageModeShared)
      }
      return emptyGroupBuffer
    }

    /// Builds the outline distance field for the current selection: seeds the
    /// field from the id AOVs, then jump-floods nearest-silhouette coords.
    /// Only enough passes to cover the outline band are run here, which
    /// means (step = 2^k .. 1, starting just above `outlineWidth`), so
    /// cost is independent of viewport size and near-constant for our thin
    /// outlines. Returns the final field.
    private func computeOutlineField(commandBuffer: MTLCommandBuffer,
                                     primTex: MTLTexture, instTex: MTLTexture,
                                     depthTex: MTLTexture,
                                     groupBuffer: MTLBuffer?,
                                     modelBuffer: MTLBuffer?,
                                     uniforms: inout OutlineUniforms) -> MTLTexture?
    {
      guard let maskPipeline = jfaMaskPipelineState,
            let dilatePipeline = jfaDilatePipelineState,
            let erodePipeline = jfaErodePipelineState,
            let seedPipeline = jfaSeedPipelineState,
            let stepPipeline = jfaStepPipelineState,
            let groupBuffer
      else { return nil }

      let w = primTex.width, h = primTex.height
      ensureJFATextures(width: w, height: h)
      guard jfaSeedTextures.count == 2, jfaMaskTextures.count == 2, jfaLabelTextures.count == 2
      else { return nil }

      let threads = MTLSize(width: 16, height: 16, depth: 1)
      let groups = MTLSize(width: (w + 15) / 16, height: (h + 15) / 16, depth: 1)

      func encode(_ pipeline: MTLComputePipelineState,
                  _ configure: (MTLComputeCommandEncoder) -> Void) -> Bool
      {
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return false }
        encoder.setComputePipelineState(pipeline)
        configure(encoder)
        encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: threads)
        encoder.endEncoding()
        return true
      }

      // close the presence mask (dilate then erode):
      // mask[0] -> mask[1] -> mask[0].
      func closePresence() -> Bool
      {
        encode(dilatePipeline, { encoder in
          encoder.setTexture(jfaMaskTextures[0], index: 0)
          encoder.setTexture(jfaMaskTextures[1], index: 1)
        }) &&
        encode(erodePipeline, { encoder in
          encoder.setTexture(jfaMaskTextures[1], index: 0)
          encoder.setTexture(jfaMaskTextures[0], index: 1)
        })
      }

      if uniforms.selectAll != 0
      {
        // per-object path: label every pixel by its model,
        // then seed the borders between different objects
        // (and against the background).
        guard let labelPipeline = jfaLabelPipelineState,
              let fillPipeline = jfaLabelFillPipelineState,
              let labelSeedPipeline = jfaLabelSeedPipelineState,
              let modelBuffer
        else { return nil }

        // label + presence:
        // id/depth/modelLUT -> label[0], presence in mask[0].
        guard encode(labelPipeline, { encoder in
          encoder.setTexture(primTex, index: 0)
          encoder.setTexture(depthTex, index: 1)
          encoder.setTexture(jfaLabelTextures[0], index: 2)
          encoder.setTexture(jfaMaskTextures[0], index: 3)
          encoder.setBytes(&uniforms, length: MemoryLayout<OutlineUniforms>.stride, index: 0)
          encoder.setBuffer(modelBuffer, offset: 0, index: 1)
        }), closePresence() else { return nil }

        // fill antialiased label holes inside the closed mask:
        // label[0] -> label[1].
        guard encode(fillPipeline, { encoder in
          encoder.setTexture(jfaLabelTextures[0], index: 0)
          encoder.setTexture(jfaMaskTextures[0], index: 1)
          encoder.setTexture(jfaLabelTextures[1], index: 2)
        }) else { return nil }

        // seed every object border:
        // label[1] + closed mask -> seed[0].
        guard encode(labelSeedPipeline, { encoder in
          encoder.setTexture(jfaLabelTextures[1], index: 0)
          encoder.setTexture(jfaMaskTextures[0], index: 1)
          encoder.setTexture(jfaSeedTextures[0], index: 2)
        }) else { return nil }
      }
      else
      {
        // single-selection path: id AOVs -> clean majority silhouette in mask[0].
        // The group table drives model-pick membership, dummy for id-pair picks.
        guard encode(maskPipeline, { encoder in
          encoder.setTexture(primTex, index: 0)
          encoder.setTexture(instTex, index: 1)
          encoder.setTexture(jfaMaskTextures[0], index: 2)
          encoder.setTexture(depthTex, index: 3)
          encoder.setBytes(&uniforms, length: MemoryLayout<OutlineUniforms>.stride, index: 0)
          encoder.setBuffer(groupBuffer, offset: 0, index: 1)
        }), closePresence() else { return nil }

        // seed the silhouette boundary of the closed mask:
        // mask[0] -> seed[0].
        guard encode(seedPipeline, { encoder in
          encoder.setTexture(jfaMaskTextures[0], index: 0)
          encoder.setTexture(jfaSeedTextures[0], index: 1)
        }) else { return nil }
      }

      // flood passes: start at the smallest power of two
      // past the outline width (all we need to resolve
      // the band) and halve down to a single texel.
      let bandwidth = max(1, Int(uniforms.outlineWidth))
      var step = 1
      while step < bandwidth + 1 { step <<= 1 }

      var src = 0
      while step >= 1
      {
        let dst = 1 - src
        guard let stepEncoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
        stepEncoder.setComputePipelineState(stepPipeline)
        stepEncoder.setTexture(jfaSeedTextures[src], index: 0)
        stepEncoder.setTexture(jfaSeedTextures[dst], index: 1)
        var s = UInt32(step)
        stepEncoder.setBytes(&s, length: MemoryLayout<UInt32>.stride, index: 0)
        stepEncoder.dispatchThreadgroups(groups, threadsPerThreadgroup: threads)
        stepEncoder.endEncoding()
        src = dst
        step >>= 1
      }

      return jfaSeedTextures[src]
    }

    /// Reads sample 0 of the primId/instanceId AOVs under a click and stores
    /// them on the engine for the outline shader. Background reads back as a
    /// negative id, which naturally clears the outline on a miss.
    private func resolveSelection(viewPoint: CGPoint, viewSize: CGSize, drawableSize: CGSize)
    {
      #if canImport(Usd)
        guard let primHgi = hydra?.aovTexture(.primId),
              let instHgi = hydra?.aovTexture(.instanceId),
              let primTex = primHgi.asMetalTexture,
              let instTex = instHgi.asMetalTexture,
              let pipeline = selectionReadPipelineState,
              let queue = commandQueue
        else { print("[hydra] selection: id AOV textures unavailable"); return }

        // hydra's AOV textures are y-up (row 0 = bottom),
        // the same basis the outline shader reads them in
        // via texcoord, so the click point (AppKit y-up)
        // maps straight through with no flip.
        let sx = drawableSize.width / max(viewSize.width, 1)
        let sy = drawableSize.height / max(viewSize.height, 1)
        let px = min(max(0, Int(viewPoint.x * sx)), primTex.width - 1)
        let py = min(max(0, Int(viewPoint.y * sy)), primTex.height - 1)

        guard let out = device.makeBuffer(length: MemoryLayout<SIMD2<Int32>>.stride,
                                          options: .storageModeShared),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(primTex, index: 0)
        encoder.setTexture(instTex, index: 1)
        encoder.setBuffer(out, offset: 0, index: 0)
        var coord = SIMD2<UInt32>(UInt32(px), UInt32(py))
        encoder.setBytes(&coord, length: MemoryLayout<SIMD2<UInt32>>.stride, index: 1)
        encoder.dispatchThreadgroups(MTLSize(width: 1, height: 1, depth: 1),
                                     threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let ids = out.contents().load(as: SIMD2<Int32>.self)
        hydra?.selectedPrimId = ids.x
        hydra?.selectedInstanceId = ids.y
      #endif
    }
  }
}

#if canImport(Usd)
extension Pixar.HgiTexture
{
  public var asMetalTexture: MTLTexture?
  {
    let rawResource = self.GetRawResource()
    guard
      rawResource != 0,
      let ptr = UnsafeRawPointer(bitPattern: UInt(rawResource))
    else { return nil }

    return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue() as? any MTLTexture
  }
}
#else // !canImport(Usd)
extension Pixar.HgiTextureHandle
{
  public var asMetalTexture: MTLTexture?
  {
    // get the hgi texture from the hgi texture handle.
    return Overlay.HgiTextureHandleGetTextureId(self)
  }
}
#endif // canImport(Usd)

#endif // canImport(Metal)
