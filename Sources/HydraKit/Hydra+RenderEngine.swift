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

    /// The timecode to draw at. Defaults to the stage's authored start, so a
    /// time-sampled asset shows its first real frame instead of an arbitrary
    /// time 0. Set it to scrub or playback animation.
    public var currentTimeCode: Double = 0.0

    /// The timecode the last frame was actually drawn at. A pick has to test
    /// the same pose that is on screen, on time-sampled geometry, picking
    /// at a different time tests a different pose and the ray lands on whatever
    /// is behind what the user actually clicked.
    private var lastRenderTimeCode: Double = 0.0

    /// The color of the custom selection outline (RGBA, 0...1). Settable at
    /// runtime, takes effect on the next frame while something is selected.
    /// Defaults to an orange color `(1.0, 0.6, 0.0, 1.0)`.
    public var selectionOutlineColor: Pixar.GfVec4f
    /// The width of the selection outline, in pixels. Settable at runtime.
    /// Defaults to a width value of `4` pixels.
    public var selectionOutlineWidth: Int32

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

      viewCamera = Hydra.Camera(isZUp: Hydra.RenderEngine.isZUp(for: stage))
      setupCamera()
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

      lastRenderTimeCode = timeCode

      var params = UsdImagingGL.RenderParams()
      params.frame = Usd.TimeCode(timeCode)
      params.clearColor = .init(0.0, 0.0, 0.0, 1.0)
      params.colorCorrectionMode = self.colorCorrectionMode
      params.showGuides = true
      params.showRender = true
      params.showProxy = true
      params.highlight = false

      // render the frame.
      engine.render(rootPrim: stage.getPseudoRoot(), params: params)

      // return the color output.
      return engine.getAovTexture(.color)
    }

    /// The id AOV textures the custom selection outline reads. Uses the render
    /// buffer, not the task context, since `getAovTexture` only publishes the
    /// viewport (color) AOV there, so the id AOVs would come back nil.
    public func aovTexture(_ aov: Hd.AovTokens) -> RenderTexture
    {
      #if canImport(UsdImagingGL)
        return engine.aovRenderBuffer(aov)
      #else
        // todo(furbytm): (no-op) expose GetAovRenderBuffer(_:) in apple/SwiftUsd.
        return Pixar.HgiTextureHandle()
      #endif
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

    /// Pans ("tracks") the view, `Shift+MMB`. Slides the focus point in the camera's screen
    /// plane so the scene follows the pointer 1:1 at the focus depth. `deltaX`/`deltaY` are
    /// pointer motion in points (AppKit basis: +x right, +y down). `viewHeight` is the viewport
    /// height in the same units.
    public func pan(deltaX: Double, deltaY: Double, viewHeight: Double)
    {
      guard viewHeight > 0 else { return }

      // the frustum's 24mm filmback gives tan(fov/2) = 12 / focalLength, so the
      // world height visible at the focus distance is 24 * distance / focalLength.
      let worldPerPixel = (24.0 * viewCamera.params.distance
                           / max(viewCamera.params.focalLength, 0.001)) / viewHeight

      let (right, up) = viewCamera.screenAxes()

      // moving the focus opposite the pointer's horizontal motion, and with its
      // vertical motion (screen +y is down, world up is `up`), makes the scene
      // track the cursor.
      viewCamera.params.focus[0] += (up[0] * deltaY - right[0] * deltaX) * worldPerPixel
      viewCamera.params.focus[1] += (up[1] * deltaY - right[1] * deltaX) * worldPerPixel
      viewCamera.params.focus[2] += (up[2] * deltaY - right[2] * deltaX) * worldPerPixel
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
      viewCamera.params.focus = worldCenter
      viewCamera.params.distance = max(worldSize, 0.01)
    }

    /// Frames the last-picked prim, keeping the current orientation `Numpad-.`
    /// (View Selected). Falls back to framing everything on no pick.
    public func frameSelected()
    {
      stopFlick()
      guard let path = lastPickedPath else { frameAll(); return }

      var bboxCache = computeBBoxCache()
      let bbox = bboxCache.ComputeWorldBound(stage.GetPrimAtPath(path))
      let range = bbox.ComputeAlignedRange()

      #if canImport(Gf)
      guard !range.IsEmpty() else { frameAll(); return }
      let targetFocus = (range.GetMin().pointee + range.GetMax().pointee) / 2.0
      #else
      guard !range.IsEmpty() else { frameAll(); return }
      let targetFocus = (range.GetMin() + range.GetMax()) / 2.0
      #endif
      let targetDistance = max(range.GetSize().GetLength(), 0.01)
      
      animateCamera(toFocus: targetFocus, distance: targetDistance)
    }
    
    private func animateCamera(toFocus targetFocus: Pixar.GfVec3d, distance targetDistance: Double)
    {
      focusAnimationTimer?.invalidate()

      let startFocus = viewCamera.params.focus
      let startDistance = viewCamera.params.distance
      let startTime = Date()

      let timer = Foundation.Timer(timeInterval: Self.flickInterval as TimeInterval, repeats: true)
      { [weak self] timer in
        guard let self else { timer.invalidate(); return }

        let t = min(Date().timeIntervalSince(startTime) / Self.focusAnimationDuration, 1.0)
        let eased = 1 - pow(1 - t, 3) // ease-out cubic: fast start, gentle settle.

        viewCamera.params.focus = startFocus + (targetFocus - startFocus) * eased
        viewCamera.params.distance = startDistance + (targetDistance - startDistance) * eased

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
        case .front:  viewCamera.params.rotation = .init(0.0, 0.0, 0.0)
        case .back:   viewCamera.params.rotation = .init(0.0, 180.0, 0.0)
        case .right:  viewCamera.params.rotation = .init(0.0, -90.0, 0.0)
        case .left:   viewCamera.params.rotation = .init(0.0, 90.0, 0.0)
        case .top:    viewCamera.params.rotation = .init(-90.0, 0.0, 0.0)
        case .bottom: viewCamera.params.rotation = .init(90.0, 0.0, 0.0)
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

    /// What a viewport pick landed on, the gprim under the cursor,
    /// and, when that gprim is drawn by an instancer, which instance
    /// it was.
    public struct PickResult
    {
      /// The gprim selected by the pick.
      public let primPath: Sdf.Path
      /// The point instancer of that gprim, or an empty path if it is not
      /// instanced. With an aggregating scene this is the prim instancer,
      /// and ``instanceIndex`` is the cell.
      public let instancerPath: Sdf.Path
      /// The instance index within ``instancerPath``, or `-1` when not instanced.
      public let instanceIndex: Int
      /// The hit position in world space.
      public let worldPoint: Gf.Vec3d

      /// Whether the pick resolved to an instance of a prim instancer.
      public var isInstance: Bool { !instancerPath.IsEmpty() }
    }

    /// Called after a click that resolved to geometry (or with `nil` on a miss).
    /// Set it to react to picks, the viewport invokes it on the main thread.
    public var onPick: ((PickResult?) -> Void)?

    /// A click waiting for the renderer to read the id AOVs under it. The Metal
    /// readback needs the renderer's command queue, so `pick` records the
    /// request here and the renderer fulfils it on its next frame.
    public var pendingSelection: (point: CGPoint, viewSize: CGSize)?

    /// The id AOV values under the last resolved click, or `-1`.
    /// The selection-outline shader edge-detects the region that
    /// matches these. Written by the renderer after its readback.
    public var selectedPrimId: Int32 = -1
    public var selectedInstanceId: Int32 = -1

    /// Set when the last pick resolved to a model (a non-instanced prim): the
    /// outline then covers every prim in that model via `selectionGroup`
    /// rather than the single (primId, instanceId) pair.
    public var selectionUsesGroup: Bool = false
    /// `1` at index `primId` for each prim id in the picked model, else `0`.
    /// The outline mask kernel tests membership here. Empty when not a
    /// model pick.
    public var selectionGroup: [Int32] = []
    /// Bumped whenever `selectionGroup` changes, so the renderer rebuilds its
    /// GPU copy only on a new model pick.
    public var selectionGroupVersion: Int = 0

    /// Set when everything is selected (`A`): the outline then
    /// covers every prim, ignoring the id-pair and group state.
    public var selectionSelectAll: Bool = false

    /// Maps each rprim's id-AOV value to its model id (a small sequential
    /// id per enclosing model, 0 = none), so select-all can outline every
    /// object individually - the outline mask kernel seeds a border when
    /// this changes. Built once, alongside `primIdPathCache`.
    public private(set) var selectionModelLUT: [Int32] = []
    /// Bumped when `selectionModelLUT` is (re)built, so the
    /// renderer rebuilds its GPU copy only when needed.
    public private(set) var selectionModelLUTVersion: Int = 0

    /// Lazily-built map of every rprim's id-AOV value to its scene path, reused
    /// across picks (a stage's rprim ids are stable). Resolving a model pick is
    /// then a cheap prefix test over this rather than a fresh decode of the scene.
    private var primIdPathCache: [(id: Int32, path: Sdf.Path)]?

    /// The gprim of the most recent successful pick, so "frame selected"
    /// has a target. Cleared on a miss.
    public private(set) var lastPickedPath: Sdf.Path?

    /// Intersects the scene under `point` and returns what was hit, or `nil`.
    ///
    /// `point` is in the view's own coordinates: origin bottom-left, y up, to
    /// match AppKit. The current view camera is reused and narrowed to a few
    /// pixels around the point, so a click selects what is under the cursor
    /// rather than everything along the ray.
    public func pick(at point: CGPoint, viewSize: CGSize) -> PickResult?
    {
      guard viewSize.width > 0, viewSize.height > 0 else { return nil }

      // ask the renderer to read the id AOVs under this click
      // (hit or miss: a miss reads background and clears the
      // outline).
      pendingSelection = (point, viewSize)

      let cameraTransform = viewCamera.getTransform()
      let cameraParams = viewCamera.getShaderParams()
      let frustum = computeFrustum(cameraTransform: cameraTransform,
                                   viewSize: viewSize,
                                   cameraParams: cameraParams)

      // view point -> normalized device coords in [-1, 1].
      let ndcX = (Double(point.x) / Double(viewSize.width)) * 2.0 - 1.0
      let ndcY = (Double(point.y) / Double(viewSize.height)) * 2.0 - 1.0

      // a few extra pixels of padding, so the pick has a forgiving target.
      let pickRadius = 6.0
      let size = Gf.Vec2d(pickRadius / Double(viewSize.width),
                          pickRadius / Double(viewSize.height))

      let pickFrustum = frustum.ComputeNarrowedFrustum(Gf.Vec2d(ndcX, ndcY), size)
      let viewMatrix = pickFrustum.computeViewMatrix()
      let projMatrix = pickFrustum.computeProjectionMatrix()

      var params = UsdImagingGL.RenderParams()
      // the same timecode the frame was drawn at, so
      // the pick tests the pose that is actually on
      // screen (see `lastRenderTimeCode`).
      params.frame = Usd.TimeCode(lastRenderTimeCode)
      params.showGuides = true
      params.showRender = true
      params.showProxy = true

      var hitPoint = Gf.Vec3d()
      var hitNormal = Gf.Vec3d()
      var primPath = Sdf.Path()
      var instancerPath = Sdf.Path()
      var instanceIndex: Int32 = -1

      let hit = engine.TestIntersection(viewMatrix,
                                        projMatrix,
                                        stage.getPseudoRoot(),
                                        params,
                                        &hitPoint,
                                        &hitNormal,
                                        &primPath,
                                        &instancerPath,
                                        &instanceIndex,
                                        nil)

      // drive hydra's own selection so the hit lights up
      // on the next frame. a miss clears it, so clicking
      // empty space deselects.
      engine.ClearSelected()

      // the model-scope and select-all outlines use these flags; reset them each
      // pick so a stale selection never lingers (a miss or instance pick clears).
      selectionUsesGroup = false
      selectionSelectAll = false

      guard hit else
      {
        selectionGroup = []
        lastPickedPath = nil
        return nil
      }

      lastPickedPath = primPath

      if !instancerPath.IsEmpty()
      {
        // an instanced hit highlights the specific instance
        // that was drawn, which, on the aggregating path, is
        // the cell the pick resolved to - kept individually
        // selectable via (primId, instanceId).
        engine.AddSelected(instancerPath, instanceIndex)
      }
      else
      {
        // a plain prim outlines its whole model, so the
        // outline reads as a per-object selection rather
        // than a single mesh.
        selectModel(root: modelRoot(of: primPath))
        engine.AddSelected(primPath, -1)
      }

      return PickResult(primPath: primPath,
                        instancerPath: instancerPath,
                        instanceIndex: Int(instanceIndex),
                        worldPoint: hitPoint)
    }

    /// The enclosing model of `path` - the nearest ancestor (or the prim itself)
    /// that is a model but not a group, (i.e. a component, matching usdview's model
    /// pick mode). Falls back to `path` when the prim is not inside a model, so the
    /// outline still covers at least the picked prim.
    private func modelRoot(of path: Sdf.Path) -> Sdf.Path
    {
      var prim = stage.GetPrimAtPath(path)
      guard prim.IsValid() else { return path }

      var root: Sdf.Path?
      while prim.IsValid(), !prim.IsPseudoRoot()
      {
        if prim.IsModel(), !prim.IsGroup() { root = prim.GetPath() }
        prim = prim.GetParent()
      }
      return root ?? path
    }

    /// Every rprim id paired with its scene path, built once and reused. rprim
    /// ids are assigned densely from 1, so this walks them decoding to paths
    /// and stops after a long run of gaps. Returns empty when the decode is
    /// unavailable.
    private func ensurePrimIdPathCache() -> [(id: Int32, path: Sdf.Path)]
    {
      if let cache = primIdPathCache { return cache }

      var cache: [(id: Int32, path: Sdf.Path)] = []
      var misses = 0
      var id: Int32 = 1
      while misses < 1024, id < 1_000_000
      {
        if let path = engine.decodePrimPath(primId: id, instanceId: -1)
        {
          cache.append((id: id, path: path)); misses = 0
        }
        else { misses += 1 }
        id += 1
      }
      primIdPathCache = cache
      return cache
    }

    /// Flags every rprim id under `root` for the outline. Leaves the selection
    /// single-prim (via `selectedPrimId`) when the model has no resolved
    /// ids. (e.g. the decode is unavailable, so this degrades rather than clears).
    private func selectModel(root: Sdf.Path)
    {
      let cache = ensurePrimIdPathCache()
      guard let maxId = cache.map({ $0.id }).max() else { return }

      var lut = [Int32](repeating: 0, count: Int(maxId) + 1)
      for entry in cache where entry.path.HasPrefix(root)
      {
        lut[Int(entry.id)] = 1
      }

      selectionGroup = lut
      selectionUsesGroup = true
      selectionGroupVersion += 1
    }

    /// Discards the cached id -> path map, forcing a rebuild
    /// on the next model pick. Called after the stage's rprim
    /// topology changes.
    public func invalidateSelectionGroupCache()
    {
      primIdPathCache = nil
      selectionModelLUT = []
    }

    /// Selects every prim (`A`), outlining
    /// each object individually.
    public func selectAll()
    {
      ensureModelLUT()
      selectionSelectAll = true
      selectionUsesGroup = false
      selectionGroup = []
    }

    /// Builds the primId -> model-id table once: every rprim is mapped
    /// to a small sequential id for its enclosing model, so select-all can
    /// tell objects apart. Empty when the decode is unavailable.
    private func ensureModelLUT()
    {
      guard selectionModelLUT.isEmpty else { return }

      let cache = ensurePrimIdPathCache()
      guard let maxId = cache.map({ $0.id }).max() else { return }

      // the model id is the model root path's hash (0 reserved for background);
      // the mask kernel only compares labels for equality, so distinct values
      // per model are all that matters.
      var lut = [Int32](repeating: 0, count: Int(maxId) + 1)
      for entry in cache
      {
        var modelId = Int32(truncatingIfNeeded: modelRoot(of: entry.path).GetHash())
        if modelId == 0 { modelId = 1 }
        lut[Int(entry.id)] = modelId
      }

      selectionModelLUT = lut
      selectionModelLUTVersion += 1
    }

    /// Clears the current selection and its outline.
    /// The keyboard equivalent of clicking empty
    /// space (`Alt+A` / deselect all).
    public func clearSelection()
    {
      selectedPrimId = -1
      selectedInstanceId = -1
      selectionUsesGroup = false
      selectionSelectAll = false
      selectionGroup = []
      lastPickedPath = nil
      engine.ClearSelected()
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
