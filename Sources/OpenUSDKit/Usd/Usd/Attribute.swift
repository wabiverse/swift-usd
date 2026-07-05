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

import CxxStdlib
#if canImport(Usd)
  import Usd
#else
  import OpenUSD
#endif

public typealias UsdAttribute = Pixar.UsdAttribute

public extension Usd
{
  typealias Attribute = UsdAttribute
}

public extension Usd.Attribute
{
  func set(doc: String)
  {
    doc.withCString { Overlay.SetDocumentation(self, $0) }
  }

  @discardableResult
  func set(_ value: String, time: UsdTimeCode = UsdTimeCode.Default()) -> Bool
  {
    value.withCString { Overlay.SetAttributeString(self, $0, time) }
  }
  
  @discardableResult
  func set(_ value: Double, time: UsdTimeCode = UsdTimeCode.Default()) -> Bool
  {
    Set(value, time)
  }
  
  @discardableResult
  func set(_ value: GfVec3f, time: UsdTimeCode = UsdTimeCode.Default()) -> Bool
  {
    Set(value, time)
  }
  
  @discardableResult
  func set(_ value: GfVec3d, time: UsdTimeCode = UsdTimeCode.Default()) -> Bool
  {
    Set(value, time)
  }

  @discardableResult
  func set(_ value: Sdf.AssetPath, time: UsdTimeCode = UsdTimeCode.Default()) -> Bool
  {
    Set(value, time)
  }
  
  #if canImport(Usd)
  private borrowing func GetTypeNameCopy() -> Pixar.SdfValueTypeName
  {
    __GetTypeNameUnsafe()
  }
  #endif

  var typeName: Pixar.SdfValueTypeName
  {
    get
    {
      #if canImport(Usd)
        GetTypeNameCopy()
      #else
        GetTypeName()
      #endif
    }
    set { SetTypeName(newValue) }
  }
  
  /// Returns `true` if `IsValid()` is `true`, otherwise `false`.
  func isValid() -> Bool
  {
    IsValid()
  }
  
  /// Returns `self` if `IsValid()`, otherwise `nil`.
  var validOrNil: Usd.Attribute?
  {
    IsValid() ? self : nil
  }
}

#if !canImport(Usd)
extension Overlay
{
  public static func SetDocumentation(_ attr: Pixar.UsdAttribute, _ doc: UnsafePointer<CChar>)
  {
    attr.SetDocumentation(std.string(doc))
  }
  
  public static func SetAttributeString(_ attr: Pixar.UsdAttribute, _ value: UnsafePointer<CChar>, _ time: UsdTimeCode) -> Bool
  {
    attr.Set(std.string(value), time)
  }
}
#endif
