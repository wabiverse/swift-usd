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

#if canImport(UsdShade)
  import UsdShade
#else
  import OpenUSD
#endif

public typealias UsdShadeShader = Pixar.UsdShadeShader

public extension UsdShade
{
  typealias Shader = UsdShadeShader
}

public extension UsdShade.Shader
{
  @discardableResult
  static func define(_ stage: UsdStage, path: Sdf.Path) -> UsdShade.Shader
  {
    UsdShade.Shader.Define(Overlay.TfWeakPtr(stage), path)
  }

  @discardableResult
  static func define(_ stage: UsdStage, path: String) -> UsdShade.Shader
  {
    UsdShade.Shader.define(stage, path: .init(path))
  }

  @discardableResult
  func createIdAttr(_ defaultValue: Tf.Token, writeSparsely: Bool = false) -> Usd.Attribute
  {
    CreateIdAttr(VtValue(defaultValue), writeSparsely)
  }

  @discardableResult
  func createIdAttr(_ defaultValue: String, writeSparsely: Bool = false) -> Usd.Attribute
  {
    defaultValue.withCString { Overlay.CreateIdAttr(self, $0, writeSparsely) }
  }

  /**
   * Common shader ids, for convenience.
   */
  enum ShaderId: String, CaseIterable
  {
    case pxrSurface = "PxrSurface"
    case usdPreviewSurface = "UsdPreviewSurface"
    case usdUVTexture = "UsdUVTexture"

    public func getToken() -> Tf.Token
    {
      Tf.Token(rawValue)
    }
  }

  @discardableResult
  func createIdAttr(_ defaultValue: ShaderId, writeSparsely: Bool = false) -> Usd.Attribute
  {
    CreateIdAttr(VtValue(defaultValue.getToken()), writeSparsely)
  }

  @discardableResult
  mutating func createInput(for name: Tf.Token, type: SdfValueTypeNameType) -> UsdShade.Input
  {
    CreateInput(name, Sdf.getValueType(for: type))
  }

  /**
   * Common shader inputs, for convenience.
   */
  enum InputName: String, CaseIterable
  {
    /* ----- usd preview surface. ----- */

    case diffuseColor
    case roughness
    case specularColor
    case metallic
    case emissiveColor
    case clearcoat
    case clearcoatRoughness
    case opacity
    case ior
    case normal
    case displacement
    case occlusion

    /* ---------- usd uv texture. ----- */

    case file
    case st
    case wrapS
    case wrapT
    case fallback
    case scale
    case bias
    case sourceColorSpace

    public func getToken() -> Tf.Token
    {
      Tf.Token(rawValue)
    }
  }

  @discardableResult
  mutating func createInput(for name: InputName, type: SdfValueTypeNameType) -> UsdShade.Input
  {
    CreateInput(name.getToken(), Sdf.getValueType(for: type))
  }

  @discardableResult
  mutating func createInput(for name: String, type: SdfValueTypeNameType) -> UsdShade.Input
  {
    CreateInput(Tf.Token(name), Sdf.getValueType(for: type))
  }

  func connectableAPI() -> UsdShade.ConnectableAPI
  {
    ConnectableAPI()
  }
}

#if !canImport(UsdShade)
extension Overlay
{
  public static func CreateIdAttr(_ shader: Pixar.UsdShadeShader, _ defaultValue: UnsafePointer<CChar>, _ writeSparsely: Bool) -> Pixar.UsdAttribute
  {
    shader.CreateIdAttr(Pixar.VtValue(Tf.Token(String(cString: defaultValue))), writeSparsely)
  }
}
#endif
