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
#else // !canImport(Metal)
  import HgiGL
#endif // canImport(Metal)

public enum Hydra
{
  public class RenderEngine: @unchecked Sendable
  {
    public var stage: UsdStage

#if canImport(Metal)
    private let hgi: Pixar.HgiMetal
#else // !canImport(Metal)
    private let hgi: Pixar.HgiGL
#endif // canImport(Metal)
    
    #if canImport(UsdImagingGL)
    private let engine: UsdImagingGL.Engine
    #else
    // apple/swiftusd's engine type is a value type:
    // https://github.com/apple/SwiftUsd/issues/27
    private var engine: UsdImagingGL.Engine
    #endif
    
    /// Weak: the app drives the frame, the engine doesn't own the driver.
    public weak var frameDelegate: Hydra.FrameDelegate?
    
    private var populateTask: Task<Void, Never>?
    
    /// The color management mode applied during rendering.
    ///
    /// Expected tokens include:
    /// - `.disabled`: Raw linear color values are passed straight through.
    /// - `.sRGB`: Applies a standard sRGB gamma curve without filmic compression.
    /// - `.openColorIO`: Activates OpenColorIO processing for advanced cinematic
    ///   tonemapping (requires a valid `.ocio` configuration).
    public var colorCorrectionMode: Tf.Token
    
    private var viewCamera: Hydra.Camera

    private var worldCenter: Pixar.GfVec3d = .init(0.0, 0.0, 0.0)
    private var worldSize: Double = 1.0

    private var material = Pixar.GlfSimpleMaterial()
    private var sceneAmbient = Pixar.GfVec4f(0.01, 0.01, 0.01, 1.0)

    /// "click-and-flick" coast: keeps orbiting at a decaying velocity after the drag ends,
    /// then settles to a stop (see `flick(deltaYaw:deltaPitch:)`).
    private var flickTimer: Foundation.Timer?
    private var flickVelocity: (yaw: Double, pitch: Double) = (0.0, 0.0)

    private static let flickInterval: TimeInterval = 1.0 / 60.0
    private static let flickDamping: Double = 0.94
    private static let flickThreshold: Double = 0.01
    
    // sorted args with default arguments in order from most
    // common to least commonly used, for simplified ergonomics.
    public required init(stage: UsdStage,
                         colorCorrectionMode: Tf.Token = .sRGB,
                         rendererPluginId: Tf.Token = Tf.Token(),
                         excludedPaths: Sdf.PathVector = Sdf.PathVector(),
                         invisedPaths: Sdf.PathVector = Sdf.PathVector(),
                         sceneDelegateId: Sdf.Path = Sdf.Path.absoluteRootPath(),
                         allowAsynchronousSceneProcessing: Bool = false,
                         enableUsdDrawModes: Bool = true,
                         displayUnloadedPrimsWithBounds: Bool = false,
                         gpuEnabled: Bool = true)
    {
      self.stage = stage
      self.colorCorrectionMode = colorCorrectionMode

#if canImport(Metal)
      hgi = HgiMetal.createHgi()
      let driver = HdDriver(name: .renderDriver, driver: hgi.value)
#else // !canImport(Metal)
      hgi = HgiGL.createHgi()
      let driver = HdDriver(name: .renderDriver, driver: hgi.value)
#endif // canImport(Metal)

      engine = UsdImagingGL.Engine.createEngine(
        rootPath: stage.getPseudoRoot().getPath(),
        excludedPaths: excludedPaths,
        invisedPaths: invisedPaths,
        sceneDelegateId: sceneDelegateId,
        driver: driver,
        rendererPluginId: rendererPluginId,
        gpuEnabled: gpuEnabled,
        displayUnloadedPrimsWithBounds: displayUnloadedPrimsWithBounds,
        allowAsynchronousSceneProcessing: allowAsynchronousSceneProcessing,
        enableUsdDrawModes: enableUsdDrawModes
      )

      engine.setEnablePresentation(false)
      engine.setRendererAov(.color)

      viewCamera = Hydra.Camera(isZUp: Hydra.RenderEngine.isZUp(for: stage))
      setupCamera()
      setupMaterial()
    }
    
    #if canImport(Hgi)
    public typealias RenderTexture = Optional<Pixar.HgiTexture>
    #else
    public typealias RenderTexture = Pixar.HgiTextureHandle
    #endif
    
    public func render(at timeCode: Double, viewSize: CGSize) -> RenderTexture
    {
      // draws the scene using hydra.
      let cameraTransform = viewCamera.getTransform()
      let cameraParams = viewCamera.getShaderParams()
      let frustum = computeFrustum(cameraTransform: cameraTransform, viewSize: viewSize, cameraParams: cameraParams)
      let viewMatrix = frustum.computeViewMatrix()
      let projMatrix = frustum.computeProjectionMatrix()
      engine.setCameraState(modelViewMatrix: viewMatrix, projectionMatrix: projMatrix)

      // viewport setup.
      let viewport = Gf.Vec4d(0, 0, viewSize.width, viewSize.height)
      engine.setRenderViewport(viewport)
      engine.setWindowPolicy(.matchHorizontally)

      // light and material setup.
      // let lights = computeLights(cameraTransform: cameraTransform)
      // engine.setLightingState(lights: lights, material: material, sceneAmbient: sceneAmbient)

      var params = UsdImagingGL.RenderParams()
      params.frame = Usd.TimeCode(timeCode)
      params.clearColor = .init(0.0, 0.0, 0.0, 1.0)
      params.colorCorrectionMode = self.colorCorrectionMode
      params.showGuides = true
      params.showRender = true
      params.showProxy = true

      // render the frame.
      engine.render(rootPrim: stage.getPseudoRoot(), params: params)

      // return the color output.
      return engine.getAovTexture(.color)
    }

    public func setupCamera()
    {
      calculateOriginAndSize()

      viewCamera.params.rotation = .init(0.0, 0.0, 0.0)
      viewCamera.params.focus = worldCenter
      viewCamera.params.distance = worldSize

      if worldSize <= 16.0
      {
        viewCamera.scaleBias = 1.0
      }
      else
      {
        viewCamera.scaleBias = log2(worldSize / 16.0 * 1.8) / log2(1.8)
      }

      viewCamera.params.focalLength = 18.0
      viewCamera.standardFocalLength = 18.0
    }

    /// Orbits ("tumbles") the view camera around its focus point - the classic
    /// click-and-drag navigation gesture.
    public func orbit(deltaYaw: Double, deltaPitch: Double)
    {
      viewCamera.params.rotation[1] += deltaYaw
      viewCamera.params.rotation[0] += deltaPitch
    }

    /// Dollies the view camera toward/away from its focus point by a relative
    /// `factor` (e.g. `-0.05` moves it 5% closer, `+0.05` moves it 5% further).
    public func dolly(by factor: Double)
    {
      viewCamera.params.distance = max(0.01, viewCamera.params.distance * (1.0 + factor))
    }

    /// "click-and-flick": releases the orbit drag with `deltaYaw`/`deltaPitch`
    /// and lets it keep tumbling on its own, decaying that velocity every tick until it
    /// settles to a stop, giving the inertial "coast" you'd expect from a flick gesture.
    /// calling this again (or `stopFlick()`) cancels any coast already in flight.
    public func flick(deltaYaw: Double, deltaPitch: Double)
    {
      stopFlick()

      guard deltaYaw.magnitude > Self.flickThreshold || deltaPitch.magnitude > Self.flickThreshold
      else { return }

      flickVelocity = (deltaYaw, deltaPitch)

      let timer = Foundation.Timer(timeInterval: Self.flickInterval as TimeInterval, repeats: true)
      { [weak self] timer in
        guard let self else { timer.invalidate(); return }

        orbit(deltaYaw: flickVelocity.yaw, deltaPitch: flickVelocity.pitch)

        flickVelocity.yaw *= Self.flickDamping
        flickVelocity.pitch *= Self.flickDamping

        if flickVelocity.yaw.magnitude < Self.flickThreshold, flickVelocity.pitch.magnitude < Self.flickThreshold
        {
          stopFlick()
        }
      }

      // `.common` keeps the coast ticking even while a tracking loop
      // (e.g. window resize, scroll) would otherwise starve `.default`.
      RunLoop.current.add(timer, forMode: .common)
      flickTimer = timer
    }

    /// cancels any in-flight `flick` coast (e.g. when a fresh drag begins).
    public func stopFlick()
    {
      flickTimer?.invalidate()
      flickTimer = nil
      flickVelocity = (0.0, 0.0)
    }

    /// creates a light source located at the camera position.
    //  func computeCameraLight(cameraTransform: Gf.Matrix4d) -> Pixar.GlfSimpleLight
    //  {
    //    let cameraPosition = Pixar.GfVec3f(cameraTransform.ExtractTranslation())
    //
    //    let light = Pixar.GlfSimpleLightCollector.createLight(Pixar.GfVec4f(cameraPosition[0], cameraPosition[1], cameraPosition[2], 1))
    //
    //    return light
    //  }

    // func computeLights(cameraTransform: Gf.Matrix4d) -> Pixar.GlfSimpleLightVector
    // {
    //   error: swift result not found (c:@N@std@S@allocator>#C)
    //
    //   var lightsVec = Pixar.GlfSimpleLightVector()
    //   lightsVec.push_back(computeCameraLight(cameraTransform: cameraTransform))
    //   return lightsVec
    // }

    func setupMaterial()
    {
      let kA = Float(0.2)
      let kS = Float(0.1)

      material.SetAmbient(Pixar.GfVec4f(kA, kA, kA, 1.0))
      material.SetSpecular(Pixar.GfVec4f(kS, kS, kS, 1.0))
      material.SetShininess(Double(32.0))

      sceneAmbient = Pixar.GfVec4f(Float(0.01), Float(0.01), Float(0.01), Float(1.0))
    }

    public func calculateOriginAndSize()
    {
      var bboxCache = computeBBoxCache()

      var bbox = bboxCache.ComputeWorldBound(stage.getPseudoRoot())
      
      #if canImport(Gf)
      if bbox.GetRange().pointee.IsEmpty() || isInfiniteBBox(bbox)
      {
        bbox = Pixar.GfBBox3d(.init(.init(-10, -10, -10), .init(10, 10, 10)))
      }
      #else
      if bbox.GetRange().IsEmpty() || isInfiniteBBox(bbox)
      {
        bbox = Pixar.GfBBox3d(.init(.init(-10, -10, -10), .init(10, 10, 10)))
      }
      #endif

      let world = bbox.ComputeAlignedRange()
      
      #if canImport(Gf)
      worldCenter = (world.GetMin().pointee + world.GetMax().pointee) / 2.0
      #else
      worldCenter = (world.GetMin() + world.GetMax()) / 2.0
      #endif
      worldSize = world.GetSize().GetLength()
    }

    func isInfiniteBBox(_ bbox: Pixar.GfBBox3d) -> Bool
    {
     #if canImport(Gf)
      Double(bbox.GetRange().pointee.GetMin().pointee.GetLength()).isInfinite ||
        Double(bbox.GetRange().pointee.GetMax().pointee.GetLength()).isInfinite
      #else
      Double(bbox.GetRange().GetMin().GetLength()).isInfinite ||
        Double(bbox.GetRange().GetMax().GetLength()).isInfinite
      #endif
    }

    func computeBBoxCache() -> Pixar.UsdGeomBBoxCache
    {
      var purposes = Pixar.TfTokenVector()
      purposes.push_back(UsdGeom.Tokens.default_.token)
      purposes.push_back(UsdGeom.Tokens.proxy.token)

      let useExtentHints = true
      var timeCode = UsdTimeCode.Default()
      if stage.HasAuthoredTimeCodeRange()
      {
        timeCode = UsdTimeCode(stage.GetStartTimeCode())
      }

      let bboxCache = Pixar.UsdGeomBBoxCache(timeCode, purposes, useExtentHints, false)
      return bboxCache
    }

    public func computeFrustum(cameraTransform: Gf.Matrix4d, viewSize: CGSize, cameraParams: Hydra.Camera.Params) -> Gf.Frustum
    {
      var camera = Pixar.GfCamera(
        .init(1.0),
        .init(0),
        0.825 * 2.54 / 0.1,
        0.602 * 2.54 / 0.1,
        0.0,
        0.0,
        50.0,
        .init(1, 1_000_000),
        .init(),
        0.0,
        0.0
      )
      camera.SetTransform(cameraTransform)
      var frustum = camera.GetFrustum()
      camera.SetFocalLength(Float(cameraParams.focalLength))

      if cameraParams.projection.rawValue == 0
      {
        let targetAspect = Double(viewSize.width) / Double(viewSize.height)
        let filmbackWidthMM = 24.0
        let hFOVInRadians = 2.0 * atan(0.5 * filmbackWidthMM / cameraParams.focalLength)
        let fov = (180.0 * hFOVInRadians) / Double.pi
        frustum.SetPerspective(fov, targetAspect, 1.0, 100_000.0)
      }
      else
      {
        let left = cameraParams.leftBottomNear[0] * cameraParams.scaleViewport
        let right = cameraParams.rightTopFar[0] * cameraParams.scaleViewport
        let bottom = cameraParams.leftBottomNear[1] * cameraParams.scaleViewport
        let top = cameraParams.rightTopFar[1] * cameraParams.scaleViewport
        let nearPlane = cameraParams.leftBottomNear[2]
        let farPlane = cameraParams.rightTopFar[2]
        frustum.SetOrthographic(left, right, bottom, top, nearPlane, farPlane)
      }

      return frustum
    }

#if canImport(Metal)
    public var hydraDevice: MTLDevice
    {
      hgi.device
    }

    public func getHgi() -> Pixar.HgiMetal
    {
      hgi
    }
#else // !canImport(Metal)
    public func getHgi() -> Pixar.HgiGL
    {
      hgi
    }
#endif // canImport(Metal)

    public func getEngine() -> UsdImagingGL.Engine
    {
      engine
    }

    static func isZUp(for stage: UsdStage) -> Bool
    {
      Pixar.UsdGeomGetStageUpAxis(Overlay.TfWeakPtr(stage)) == .z
    }
    
    /// Populates the stage off the main thread if this hasn't already
    /// started, then returns once population is complete. Safe to call
    /// from multiple places - population only actually runs once,
    /// backed by a single memoized task.
    @MainActor
    public func waitUntilSceneReady() async
    {
      if populateTask == nil
      {
        populateTask = Task.detached(priority: .userInitiated) { [self] in
          _ = render(at: 0, viewSize: CGSize(width: 1, height: 1))
        }
      }
      await populateTask!.value
    }
    
    /// Polls `PollForAsynchronousUpdates()` at a fixed interval, calling
    /// `onChange` on the main actor whenever the engine reports the scene
    /// changed. Requires `allowAsynchronousSceneProcessing: true`
    /// to have been passed at engine construction - otherwise this always returns
    /// `false` and `onChange` is never called, with no error to indicate why.
    ///
    /// Cancel the enclosing `Task` to stop polling.
    @MainActor
    func poll(every interval: Duration = .milliseconds(16),
              onChange: @MainActor () -> Void) async
    {
      while !Task.isCancelled
      {
        if engine.PollForAsynchronousUpdates()
        {
          onChange()
        }
        try? await Task.sleep(for: interval)
      }
    }
  }
}
