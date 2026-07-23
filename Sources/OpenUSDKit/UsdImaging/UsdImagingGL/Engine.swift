/* ----------------------------------------------------------------
 * :: :  M  E  T  A  V  E  R  S  E  :                            ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                                        Copyright (C) 2016 Pixar.
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#if canImport(UsdImagingGL)
  import UsdImagingGL
#else
  import OpenUSD
#endif

public typealias UsdImagingGLEngine = Pixar.UsdImagingGLEngine

public enum UsdImagingGL
{
  public typealias Engine = UsdImagingGLEngine
}

public extension UsdImagingGL.Engine
{
  static func createEngine(rootPath: Sdf.Path,
                           excludedPaths: Sdf.PathVector,
                           invisedPaths: Sdf.PathVector = Sdf.PathVector(),
                           sceneDelegateId: Sdf.Path = Sdf.Path.absoluteRootPath(),
                           driver: HdDriver = HdDriver(name: Tf.Token(), driver: VtValue()),
                           rendererPluginId: Tf.Token = Tf.Token(),
                           gpuEnabled: Bool = true,
                           displayUnloadedPrimsWithBounds: Bool = false,
                           allowAsynchronousSceneProcessing: Bool = false,
                           enableUsdDrawModes: Bool = true) -> UsdImagingGL.Engine
  {
    return UsdImagingGL.Engine.Create(
      rootPath,
      excludedPaths,
      invisedPaths,
      sceneDelegateId,
      driver,
      rendererPluginId,
      gpuEnabled,
      displayUnloadedPrimsWithBounds,
      allowAsynchronousSceneProcessing,
      enableUsdDrawModes
    )
  }
  
  enum CameraUtilWindowConformPolicy
  {
    case matchVertically
    case matchHorizontally
    case fit
    case crop
    case dontConform
  }
  
  #if canImport(UsdImagingGL)
  func setEnablePresentation(_ value: Bool)
  {
    SetEnablePresentation(value)
  }

  func setRendererAov(_ aovName: Hd.AovTokens)
  {
    SetRendererAov(aovName.token)
  }

  func setRendererAovs(_ aovNames: [Hd.AovTokens])
  {
    var tokens = Pixar.TfTokenVector()
    for aov in aovNames { tokens.push_back(aov.token) }
    SetRendererAovs(tokens)
  }

  func setViewportRenderOutput(_ aovName: Hd.AovTokens)
  {
    SetViewportRenderOutput(aovName.token)
  }

  func aovRenderBuffer(_ aovName: Hd.AovTokens) -> Pixar.HgiTexture?
  {
    GetAovRenderBufferTexturePtr(aovName.token)
  }
  
  func setSelectionColor(_ color: Pixar.GfVec4f)
  {
    SetSelectionColor(color)
  }

  /// Maps an id-AOV primId back to its scene path. Stateless (it uses the render
  /// index's id -> path table), so it resolves any prim, not just the last pick, which
  /// lets the outline gather every prim in a picked model.
  func decodePrimPath(primId: Int32, instanceId: Int32) -> Sdf.Path?
  {
    var path = Sdf.Path()
    let ok = DecodeIntersection(primId, instanceId, &path, nil, nil, nil)
    return (ok && !path.IsEmpty()) ? path : nil
  }

  func render(rootPrim: Usd.Prim, params: UsdImagingGL.RenderParams)
  {
    Render(rootPrim, params)
  }

  func setCameraState(modelViewMatrix: Gf.Matrix4d, projectionMatrix: Gf.Matrix4d)
  {
    SetCameraState(modelViewMatrix, projectionMatrix)
  }

  func setRenderViewport(_ viewport: Gf.Vec4d)
  {
    SetRenderViewport(viewport)
  }

  func setWindowPolicy(_ policy: CameraUtilWindowConformPolicy)
  {
    switch policy
    {
      case .matchVertically: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(0))
      case .matchHorizontally: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(1))
      case .fit: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(2))
      case .crop: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(3))
      case .dontConform: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(4))
    }
  }

  func setLightingState(lights: Pixar.GlfSimpleLightVector, material: Pixar.GlfSimpleMaterial, sceneAmbient: Pixar.GfVec4f)
  {
    SetLightingState(lights, material, sceneAmbient)
  }
  
  // todo(furbytm): align the return type with apple/swiftusd
  // by calling the standard 'GetAovTexture' method.
  func getAovTexture(_ aovName: Hd.AovTokens) -> Pixar.HgiTexture?
  {
    GetAovTexturePtr(aovName.token)
  }
  #else
  mutating func setEnablePresentation(_ value: Bool)
  {
    SetEnablePresentation(value)
  }

  mutating func setRendererAov(_ aovName: Hd.AovTokens)
  {
    SetRendererAov(aovName.token)
  }

  mutating func setRendererAovs(_ aovNames: [Hd.AovTokens])
  {
    var tokens = Pixar.TfTokenVector()
    for aov in aovNames { tokens.push_back(aov.token) }
    SetRendererAovs(tokens)
  }
  
  mutating func setViewportRenderOutput(_ aovName: Hd.AovTokens)
  {
    Msg.logger.log(level: .warning, """
      UsdImagingGL.Engine.SetViewportRenderOutput(_:) is not yet implemented for apple/SwiftUsd.
    """)
  }
  
  // todo(furbytm): expose GetAovRenderBuffer(_:) in apple/SwiftUsd.
  // mutating func aovRenderBuffer(_ aovName: Hd.AovTokens) -> Pixar.HdRenderBuffer
  // {
  //   GetAovRenderBuffer(aovName.token)
  // }
  
  mutating func setSelectionColor(_ color: Pixar.GfVec4f)
  {
    SetSelectionColor(color)
  }

  // apple/swiftusd does not expose the id -> path decode yet,
  // so model scoped outlining falls back to the single-prim
  // selection instead.
  mutating func decodePrimPath(primId: Int32, instanceId: Int32) -> Sdf.Path?
  {
    Msg.logger.log(level: .warning, """
      UsdImagingGL.Engine.decodePrimPath(primId:instanceId:) is not yet implemented for apple/SwiftUsd.
    """)
    
    return nil
  }

  mutating func render(rootPrim: Usd.Prim, params: UsdImagingGL.RenderParams)
  {
    Render(rootPrim, params)
  }

  mutating func setCameraState(modelViewMatrix: Gf.Matrix4d, projectionMatrix: Gf.Matrix4d)
  {
    SetCameraState(modelViewMatrix, projectionMatrix)
  }

  mutating func setRenderViewport(_ viewport: Gf.Vec4d)
  {
    SetRenderViewport(viewport)
  }

  mutating func setWindowPolicy(_ policy: CameraUtilWindowConformPolicy)
  {
    switch policy
    {
      case .matchVertically: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(0))
      case .matchHorizontally: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(1))
      case .fit: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(2))
      case .crop: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(3))
      case .dontConform: SetWindowPolicy(Pixar.CameraUtilConformWindowPolicy(4))
    }
  }

  mutating func setLightingState(lights: Pixar.GlfSimpleLightVector, material: Pixar.GlfSimpleMaterial, sceneAmbient: Pixar.GfVec4f)
  {
    SetLightingState(lights, material, sceneAmbient)
  }

  mutating func getAovTexture(_ aovName: Hd.AovTokens) -> Pixar.HgiTextureHandle
  {
    GetAovTexture(aovName.token)
  }
  #endif
}

#if !canImport(UsdImagingGL)
extension Pixar
{
  public typealias UsdImagingGLEngine = Overlay.UsdImagingGLEngineWrapper
}

extension Pixar.UsdImagingGLEngine
{
  // have this defer to the C++ constructor for the apple/swiftusd
  // UsdImagingGLEngineWrapper by aliasing our static method for
  // `UsdImagingGLEngine.Create` to the type itself.
  public typealias Create = UsdImagingGLEngine
}
#endif
