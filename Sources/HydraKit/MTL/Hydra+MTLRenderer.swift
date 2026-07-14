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
    private var commandQueue: MTLCommandQueue?

    private var inFlightSemaphore = DispatchSemaphore(value: 1)

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

      // drawFrame gets a fresh drawable after hgi commits.
      drawFrame(in: view, timeCode: 0.0)
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
        let metalTexture = getMetalTexture(from: hgiTexture)
      else { inFlightSemaphore.signal(); return false }

      // let hgi finish completely before we touch the drawable
      hgi.CommitPrimaryCommandBuffer()
      hgi.EndFrame()

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
      if let pipelineState
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
    
    #if canImport(Usd)
    public func getMetalTexture(from hgiTexture: Pixar.HgiTexture) -> MTLTexture?
    {
      let rawResource = hgiTexture.GetRawResource()
      guard
        rawResource != 0,
        let ptr = UnsafeRawPointer(bitPattern: UInt(rawResource))
      else { return nil }

      return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue() as? any MTLTexture
    }
    #else
    public func getMetalTexture(from handle: Pixar.HgiTextureHandle) -> MTLTexture?
    {
      // get the hgi texture from the hgi texture handle.
      return Overlay.HgiTextureHandleGetTextureId(handle)
    }
    #endif
  }
}
#endif // canImport(Metal)
