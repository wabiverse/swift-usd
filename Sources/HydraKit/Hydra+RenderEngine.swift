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
    // ----- public hydra render engine api -----
    
    /// The usd stage to render.
    public var stage: UsdStage

    /// The camera driving this view.
    public var viewCamera: Hydra.Camera
    
    /// Called for any key press the viewport itself does not claim (its own
    /// camera / selection bindings take precedence). The argument is the key's
    /// characters ignoring modifiers, (e.g. q). Games can wire this to drive
    /// input, the viewport invokes it on the main thread.
    public var onKeyDown: ((String) -> Void)?
    
    /// The color management mode applied during rendering.
    ///
    /// Expected tokens include:
    /// - `.disabled`: Raw linear color values are passed straight through.
    /// - `.sRGB`: Applies a standard sRGB gamma curve without filmic compression.
    /// - `.openColorIO`: Activates OpenColorIO processing for advanced cinematic
    ///   tonemapping (requires a valid `.ocio` configuration).
    public var colorCorrectionMode: Tf.Token
    
    /// The timecode to draw at. Defaults to the stage's authored start, so a
    /// time-sampled asset shows its first real frame instead of an arbitrary
    /// time 0. Set it to scrub or playback animation.
    public var currentTimeCode: Double = 0.0
    
    /// The color of the custom selection outline (RGBA, 0...1). Settable at
    /// runtime, takes effect on the next frame while something is selected.
    /// Defaults to an orange color `(1.0, 0.6, 0.0, 1.0)`.
    public var selectionOutlineColor: Pixar.GfVec4f
    /// The width of the selection outline, in pixels. Settable at runtime.
    /// Defaults to a width value of `4` pixels.
    public var selectionOutlineWidth: Int32
    
    /// Weak: the app drives the frame, the engine doesn't own the driver.
    public weak var frameDelegate: Hydra.FrameDelegate?
    
    // ------------------------------------------
    
#if canImport(Metal)
    private let hgi: Pixar.HgiMetal
#else // !canImport(Metal)
    private let hgi: Pixar.HgiGL
#endif // canImport(Metal)
    
    #if canImport(UsdImagingGL)
    let engine: UsdImagingGL.Engine
    #else
    // apple/swiftusd's engine type is a value type:
    // https://github.com/apple/SwiftUsd/issues/27
    var engine: UsdImagingGL.Engine
    #endif
    
    private var populateTask: Task<Void, Never>?

    /// Picking/selection state.
    var pickState = PickState()
    
    private var worldCenter: Pixar.GfVec3d = .init(0.0, 0.0, 0.0)
    private var worldSize: Double = 1.0

    /// The timecode the last frame was actually drawn at. A pick has to test
    /// the same pose that is on screen, on time-sampled geometry, picking
    /// at a different time tests a different pose and the ray lands on whatever
    /// is behind what the user actually clicked.
    var lastRenderTimeCode: Double = 0.0

    private var material = Pixar.GlfSimpleMaterial()
    private var sceneAmbient = Pixar.GfVec4f(0.01, 0.01, 0.01, 1.0)

    /// "click-and-flick" coast: keeps orbiting at a decaying velocity after the drag ends,
    /// then settles to a stop (see `flick(deltaYaw:deltaPitch:)`).
    private var flickTimer: Foundation.Timer?
    private var flickVelocity: (yaw: Double, pitch: Double) = (0.0, 0.0)

    private static let flickInterval: TimeInterval = 1.0 / 60.0
    private static let flickDamping: Double = 0.94
    private static let flickThreshold: Double = 0.01
    
    /// "focus" coast: focuses on the selected prim at a set animated duration after a
    /// user presses the respective hotkey (e.g. `f` `F`, `.`) in the viewport, then
    /// settles to a stop.
    private var focusAnimationTimer: Foundation.Timer?
    private static let focusAnimationDuration: TimeInterval = 0.3
    
    // sorted args with default arguments in order from most
    // common to least commonly used, for simplified ergonomics.
    public required init(stage: UsdStage,
                         camera: Hydra.Camera? = nil,
                         selectionColor: Pixar.GfVec4f = Pixar.GfVec4f(1.0, 0.6, 0.0, 1.0),
                         selectionOutlineWidth: Int = 4,
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
      self.selectionOutlineColor = selectionColor
      self.selectionOutlineWidth = Int32(selectionOutlineWidth)

#if canImport(Metal)
      hgi = HgiMetal.createHgi()
#else // !canImport(Metal)
      hgi = HgiGL.createHgi()
#endif // canImport(Metal)
      
      let driver = HdDriver(name: .renderDriver, driver: hgi.value)

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
      #if canImport(UsdImagingGL)
        // we needed to patch the engine to expose SetViewportRenderOutput,
        // so render the id AOVs the selection outline reads while keeping
        // color as the shown output (more than one AOV otherwise causes
        // the viewport to render blank).
        engine.setRendererAovs([.color, .primId, .instanceId, .depth])
        engine.setViewportRenderOutput(.color)
      #else
        // apple/SwiftUsd's engine has no viewport output control and no
        // render-buffer texture accessor, so the outline is unavailable
        // there, just render color.
        engine.setRendererAov(.color)
      #endif // canImport(UsdImagingGL)
      engine.setSelectionColor(selectionColor)

      // support for a user provided camera, the default
      // camera is automatically framed to the stage.
      if let camera
      {
        viewCamera = camera
        calculateOriginAndSize()
      }
      else
      {
        viewCamera = Hydra.Camera(isZUp: UsdGeom.getUpAxis(for: stage) == .z)
        setupCamera()
      }
      setupMaterial()

      currentTimeCode = stage.getStartTimeCode()
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
      let frustum = computeFrustum(cameraTransform: cameraTransform, viewSize: viewSize, camera: viewCamera)
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

      lastRenderTimeCode = timeCode

      var params = UsdImagingGL.RenderParams()
      params.frame = Usd.TimeCode(timeCode)
      params.clearColor = .init(0.0, 0.0, 0.0, 1.0)
      params.colorCorrectionMode = self.colorCorrectionMode
      params.showGuides = true
      params.showRender = true
      params.showProxy = true
      params.highlight = false
      params.clipPlanes = viewCamera.gfCamera.clippingPlanes.reduce(into: .init()) { $0.push_back(Pixar.GfVec4d($1)) }

      // render the frame.
      engine.render(rootPrim: stage.getPseudoRoot(), params: params)

      // return the color output.
      return engine.getAovTexture(.color)
    }

    #if canImport(Hgi)
    public typealias AovTexture = Optional<Pixar.HgiTexture>
    #else
    public typealias AovTexture = Optional<Pixar.HgiTextureHandle>
    #endif
    
    /// The id AOV textures the custom selection outline reads. Uses the render
    /// buffer, not the task context, since `getAovTexture` only publishes the
    /// viewport (color) AOV there, so the id AOVs would come back nil.
    public func aovTexture(_ aov: Hd.AovTokens) -> AovTexture
    {
      #if canImport(UsdImagingGL)
        return engine.aovRenderBuffer(aov)
      #else
        // todo(furbytm): (no-op) expose GetAovRenderBuffer(_:) in apple/SwiftUsd.
        return nil
      #endif
    }

    public func setupCamera()
    {
      calculateOriginAndSize()

      viewCamera.rotation = .init(0.0, 0.0, 0.0)
      viewCamera.focus = worldCenter
      viewCamera.distance = worldSize

      if worldSize <= 16.0
      {
        viewCamera.scaleBias = 1.0
      }
      else
      {
        viewCamera.scaleBias = log2(worldSize / 16.0 * 1.8) / log2(1.8)
      }

      viewCamera.gfCamera.focalLength = 18.0
      viewCamera.standardFocalLength = 18.0
    }

    /// Orbits ("tumbles") the view camera around its focus point - the classic
    /// click-and-drag navigation gesture.
    public func orbit(deltaYaw: Double, deltaPitch: Double)
    {
      viewCamera.rotation[1] += deltaYaw
      viewCamera.rotation[0] += deltaPitch
    }

    /// Dollies the view camera toward/away from its focus point by a relative
    /// `factor` (e.g. `-0.05` moves it 5% closer, `+0.05` moves it 5% further).
    public func dolly(by factor: Double)
    {
      viewCamera.distance = max(0.01, viewCamera.distance * (1.0 + factor))
    }

    /// Pans ("tracks") the view, `Shift+MMB`. Slides the focus point in the camera's screen
    /// plane so the scene follows the pointer 1:1 at the focus depth. `deltaX`/`deltaY` are
    /// pointer motion in points (AppKit basis: +x right, +y down). `viewHeight` is the viewport
    /// height in the same units.
    public func pan(deltaX: Double, deltaY: Double, viewHeight: Double)
    {
      guard viewHeight > 0 else { return }

      // tan(vFOV/2) = (verticalAperture/2) / focalLength,
      // so the world height visible at the focus distance
      // is verticalAperture * distance / focalLength.
      let worldPerPixel = (Double(viewCamera.gfCamera.verticalAperture) * viewCamera.distance
                           / max(Double(viewCamera.gfCamera.focalLength), 0.001)) / viewHeight

      let (right, up) = viewCamera.screenAxes()

      // moving the focus opposite the pointer's horizontal motion, and with its
      // vertical motion (screen +y is down, world up is `up`), makes the scene
      // track the cursor.
      viewCamera.focus[0] += (up[0] * deltaY - right[0] * deltaX) * worldPerPixel
      viewCamera.focus[1] += (up[1] * deltaY - right[1] * deltaX) * worldPerPixel
      viewCamera.focus[2] += (up[2] * deltaY - right[2] * deltaX) * worldPerPixel
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
      
      focusAnimationTimer?.invalidate()
      focusAnimationTimer = nil
    }

    /// Frames the whole scene, keeping the current orientation `Home`
    /// (View All). Unlike `setupCamera`, it does not reset the rotation.
    public func frameAll()
    {
      stopFlick()
      calculateOriginAndSize()
      viewCamera.focus = worldCenter
      viewCamera.distance = max(worldSize, 0.01)
    }

    /// Frames the last-picked prim, keeping the current orientation `Numpad-.`
    /// (View Selected). Falls back to framing everything on no pick.
    public func frameSelected()
    {
      stopFlick()
      
      // nothing picked -> frames everything.
      guard let path = lastPickedPath else { frameAll(); return }

      // include render purpose so a render-only prim frames
      // rather than coming back empty.
      var bboxCache = computeBBoxCache(includeRender: true)
      let bbox = bboxCache.ComputeWorldBound(stage.GetPrimAtPath(path))

      // something picked but no usable bound -> leaves the view where it is.
      guard !isInfiniteBBox(bbox) else { return }
      
      let range = bbox.ComputeAlignedRange()
      guard !range.IsEmpty() else { return }

      #if canImport(Gf)
      let targetFocus = (range.GetMin().pointee + range.GetMax().pointee) / 2.0
      #else
      let targetFocus = (range.GetMin() + range.GetMax()) / 2.0
      #endif
      let targetDistance = max(range.GetSize().GetLength(), 0.01)
      
      animateCamera(toFocus: targetFocus, distance: targetDistance)
    }
    
    private func animateCamera(toFocus targetFocus: Pixar.GfVec3d, distance targetDistance: Double)
    {
      focusAnimationTimer?.invalidate()

      let startFocus = viewCamera.focus
      let startDistance = viewCamera.distance
      let startTime = Date()

      let timer = Foundation.Timer(timeInterval: Self.flickInterval as TimeInterval, repeats: true)
      { [weak self] timer in
        guard let self else { timer.invalidate(); return }

        let t = min(Date().timeIntervalSince(startTime) / Self.focusAnimationDuration, 1.0)
        let eased = 1 - pow(1 - t, 3) // ease-out cubic: fast start, gentle settle.

        viewCamera.focus = startFocus + (targetFocus - startFocus) * eased
        viewCamera.distance = startDistance + (targetDistance - startDistance) * eased

        if t >= 1.0 { timer.invalidate() }
      }

      RunLoop.current.add(timer, forMode: .common)
      focusAnimationTimer = timer
    }

    /// The six axis-aligned views, for numpad navigation.
    public enum StandardView { case front, back, right, left, top, bottom }

    /// Snaps to an axis-aligned view, keeping the current focus and distance
    /// (only the orientation changes).
    public func setStandardView(_ view: StandardView)
    {
      stopFlick()
      switch view
      {
        case .front:  viewCamera.rotation = .init(0.0, 0.0, 0.0)
        case .back:   viewCamera.rotation = .init(0.0, 180.0, 0.0)
        case .right:  viewCamera.rotation = .init(0.0, -90.0, 0.0)
        case .left:   viewCamera.rotation = .init(0.0, 90.0, 0.0)
        case .top:    viewCamera.rotation = .init(-90.0, 0.0, 0.0)
        case .bottom: viewCamera.rotation = .init(90.0, 0.0, 0.0)
      }
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

      // per-prim bounds (the model level prims), so a giant
      // skydome or backdrop sphere can be rejected/ignored
      // instead of it dominating the frame and sending our
      // camera way out ~8.6 billion parsecs into the next
      // galactic universe.
      var ranges: [Pixar.GfRange3d] = []
      for top in stage.getPseudoRoot().childPrims
      {
        let kids = top.childPrims
        for prim in (kids.isEmpty ? [top] : kids)
        {
          let box = bboxCache.ComputeWorldBound(prim)
          guard !isInfiniteBBox(box) else { continue }
          let range = box.ComputeAlignedRange()
          if !range.IsEmpty() { ranges.append(range) }
        }
      }

      if let framed = framingRange(from: ranges)
      {
        #if canImport(Gf)
        worldCenter = (framed.GetMin().pointee + framed.GetMax().pointee) / 2.0
        #else
        worldCenter = (framed.GetMin() + framed.GetMax()) / 2.0
        #endif
        worldSize = max(framed.GetSize().GetLength(), 0.01)
        return
      }

      // fallback to whole scene bound, if nothing frameable was found.
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

    /// The bound to frame from per-prim `ranges`, dropping any outliers
    /// whose removal collapses the union (a backdrop/skydome that could
    /// otherwise dwarf the actual subject). Returns `nil` when there isnt
    /// something to frame.
    private func framingRange(from ranges: [Pixar.GfRange3d]) -> Pixar.GfRange3d?
    {
      guard !ranges.isEmpty else { return nil }

      var kept = ranges.sorted { diagonal(of: $0) > diagonal(of: $1) }
      while kept.count > 1
      {
        let full = diagonal(of: unionRange(kept))
        let without = diagonal(of: unionRange(Array(kept.dropFirst())))
        // a backdrop makes the union an order of magnitude larger than the rest.
        if without > 0.0, full > 20.0 * without { kept.removeFirst() } else { break }
      }
      return unionRange(kept)
    }

    private func diagonal(of range: Pixar.GfRange3d) -> Double
    {
      range.GetSize().GetLength()
    }

    private func unionRange(_ ranges: [Pixar.GfRange3d]) -> Pixar.GfRange3d
    {
      var lo: Pixar.GfVec3d?
      var hi: Pixar.GfVec3d?
      for range in ranges
      {
        #if canImport(Gf)
        let rmin = range.GetMin().pointee, rmax = range.GetMax().pointee
        #else
        let rmin = range.GetMin(), rmax = range.GetMax()
        #endif
        if let l = lo, let h = hi
        {
          lo = Pixar.GfVec3d(Swift.min(l[0], rmin[0]), Swift.min(l[1], rmin[1]), Swift.min(l[2], rmin[2]))
          hi = Pixar.GfVec3d(Swift.max(h[0], rmax[0]), Swift.max(h[1], rmax[1]), Swift.max(h[2], rmax[2]))
        }
        else { lo = rmin; hi = rmax }
      }
      return Pixar.GfRange3d(lo ?? Pixar.GfVec3d(0.0, 0.0, 0.0),
                             hi ?? Pixar.GfVec3d(0.0, 0.0, 0.0))
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

    /// A bbox cache over the interactive geometry (default + proxy). Framing a single prim also passes
    /// `includeRender: true`, so a render-purpose prim gets a real bound, whole-scene framing
    /// leaves render out, since some scenes can have a huge render-only skydome/backdrop sphere
    /// that would otherwise blow the "frame all" bound way out past the actual subject.
    func computeBBoxCache(includeRender: Bool = false) -> Pixar.UsdGeomBBoxCache
    {
      var purposes = Pixar.TfTokenVector()
      purposes.push_back(UsdGeom.Tokens.default_.token)
      purposes.push_back(UsdGeom.Tokens.proxy.token)
      if includeRender { purposes.push_back(UsdGeom.Tokens.render.token) }

      let useExtentHints = true
      var timeCode = UsdTimeCode.Default()
      if stage.HasAuthoredTimeCodeRange()
      {
        timeCode = UsdTimeCode(stage.GetStartTimeCode())
      }

      let bboxCache = Pixar.UsdGeomBBoxCache(timeCode, purposes, useExtentHints, false)
      return bboxCache
    }

    public func computeFrustum(cameraTransform: Gf.Matrix4d, viewSize: CGSize, camera: Hydra.Camera) -> Gf.Frustum
    {
      var gfCamera = camera.gfCamera
      var frustum = gfCamera.frustum

      gfCamera.transform = cameraTransform

      if gfCamera.projection.rawValue == 0
      {
        let targetAspect = Double(viewSize.width) / Double(viewSize.height)
        let hFOVInRadians = 2.0 * atan(0.5 * Double(gfCamera.horizontalAperture) / Double(gfCamera.focalLength))
        let fov = (180.0 * hFOVInRadians) / Double.pi

        let near = camera.nearClipOverride ?? 0.1
        let far = camera.farClipOverride ?? {
          // fit far to the loaded stage bounds.
          let cameraWorldPos = cameraTransform.ExtractTranslation()
          let distanceToWorldCenter = (cameraWorldPos - worldCenter).GetLength()
          return max(distanceToWorldCenter + worldSize, 1000.0)
        }()
        frustum.SetPerspective(fov, targetAspect, near, far)
      }
      else
      {
        let left = camera.leftBottomNear[0] * camera.scaleViewport
        let right = camera.rightTopFar[0] * camera.scaleViewport
        let bottom = camera.leftBottomNear[1] * camera.scaleViewport
        let top = camera.rightTopFar[1] * camera.scaleViewport
        let nearPlane = camera.nearClipOverride ?? camera.leftBottomNear[2]
        let farPlane = camera.farClipOverride ?? camera.rightTopFar[2]
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
    public func poll(every interval: Duration = .milliseconds(16),
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
