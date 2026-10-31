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

#if canImport(Sdf)
  import Sdf
#else
  import OpenUSD
#endif

public typealias SdfValueTypeNameType = Pixar.SdfValueTypeNameType
public typealias SdfValueTypeName = Pixar.SdfValueTypeName

public extension Sdf
{
  typealias ValueTypeNameType = SdfValueTypeNameType
  typealias ValueTypeName = SdfValueTypeName
}

public extension Sdf
{
  static func getValueType(for type: SdfValueTypeNameType) -> Sdf.ValueTypeName
  {
    Overlay.SdfGetValueTypeNameValue(type)
  }
}

#if canImport(Sdf)
extension Sdf.ValueTypeName: Equatable
{
  public static func == (lhs: Self, rhs: Self) -> Bool
  {
    Overlay.SdfValueTypeNameEqual(lhs, rhs)
  }
}
#endif

public extension Sdf.ValueTypeName
{
  static var bool: Self { Sdf.getValueType(for: .bool) }
  static var uChar: Self { Sdf.getValueType(for: .uChar) }
  static var int: Self { Sdf.getValueType(for: .int) }
  static var uInt: Self { Sdf.getValueType(for: .uInt) }
  static var int64: Self { Sdf.getValueType(for: .int64) }
  static var uInt64: Self { Sdf.getValueType(for: .uInt64) }

  static var half: Self { Sdf.getValueType(for: .half) }
  static var float: Self { Sdf.getValueType(for: .float) }
  static var double: Self { Sdf.getValueType(for: .double) }
  static var timeCode: Self { Sdf.getValueType(for: .timeCode) }

  static var string: Self { Sdf.getValueType(for: .string) }
  static var token: Self { Sdf.getValueType(for: .token) }
  static var asset: Self { Sdf.getValueType(for: .asset) }

  static var int2: Self { Sdf.getValueType(for: .int2) }
  static var int3: Self { Sdf.getValueType(for: .int3) }
  static var int4: Self { Sdf.getValueType(for: .int4) }
  static var half2: Self { Sdf.getValueType(for: .half2) }
  static var half3: Self { Sdf.getValueType(for: .half3) }
  static var half4: Self { Sdf.getValueType(for: .half4) }
  static var float2: Self { Sdf.getValueType(for: .float2) }
  static var float3: Self { Sdf.getValueType(for: .float3) }
  static var float4: Self { Sdf.getValueType(for: .float4) }
  static var double2: Self { Sdf.getValueType(for: .double2) }
  static var double3: Self { Sdf.getValueType(for: .double3) }
  static var double4: Self { Sdf.getValueType(for: .double4) }

  static var point3h: Self { Sdf.getValueType(for: .point3h) }
  static var point3f: Self { Sdf.getValueType(for: .point3f) }
  static var point3d: Self { Sdf.getValueType(for: .point3d) }
  static var vector3h: Self { Sdf.getValueType(for: .vector3h) }
  static var vector3f: Self { Sdf.getValueType(for: .vector3f) }
  static var vector3d: Self { Sdf.getValueType(for: .vector3d) }
  static var normal3h: Self { Sdf.getValueType(for: .normal3h) }
  static var normal3f: Self { Sdf.getValueType(for: .normal3f) }
  static var normal3d: Self { Sdf.getValueType(for: .normal3d) }
  static var color3h: Self { Sdf.getValueType(for: .color3h) }
  static var color3f: Self { Sdf.getValueType(for: .color3f) }
  static var color3d: Self { Sdf.getValueType(for: .color3d) }
  static var color4h: Self { Sdf.getValueType(for: .color4h) }
  static var color4f: Self { Sdf.getValueType(for: .color4f) }
  static var color4d: Self { Sdf.getValueType(for: .color4d) }

  static var quath: Self { Sdf.getValueType(for: .quath) }
  static var quatf: Self { Sdf.getValueType(for: .quatf) }
  static var quatd: Self { Sdf.getValueType(for: .quatd) }

  static var matrix2d: Self { Sdf.getValueType(for: .matrix2d) }
  static var matrix3d: Self { Sdf.getValueType(for: .matrix3d) }
  static var matrix4d: Self { Sdf.getValueType(for: .matrix4d) }
  static var frame4d: Self { Sdf.getValueType(for: .frame4d) }

  static var texCoord2h: Self { Sdf.getValueType(for: .texCoord2h) }
  static var texCoord2f: Self { Sdf.getValueType(for: .texCoord2f) }
  static var texCoord2d: Self { Sdf.getValueType(for: .texCoord2d) }
  static var texCoord3h: Self { Sdf.getValueType(for: .texCoord3h) }
  static var texCoord3f: Self { Sdf.getValueType(for: .texCoord3f) }
  static var texCoord3d: Self { Sdf.getValueType(for: .texCoord3d) }

  static var opaque: Self { Sdf.getValueType(for: .opaque) }
  static var group: Self { Sdf.getValueType(for: .group) }
  static var pathExpression: Self { Sdf.getValueType(for: .pathExpression) }

  static var boolArray: Self { Sdf.getValueType(for: .boolArray) }
  static var uCharArray: Self { Sdf.getValueType(for: .uCharArray) }
  static var intArray: Self { Sdf.getValueType(for: .intArray) }
  static var uIntArray: Self { Sdf.getValueType(for: .uIntArray) }
  static var int64Array: Self { Sdf.getValueType(for: .int64Array) }
  static var uInt64Array: Self { Sdf.getValueType(for: .uInt64Array) }

  static var halfArray: Self { Sdf.getValueType(for: .halfArray) }
  static var floatArray: Self { Sdf.getValueType(for: .floatArray) }
  static var doubleArray: Self { Sdf.getValueType(for: .doubleArray) }
  static var timeCodeArray: Self { Sdf.getValueType(for: .timeCodeArray) }

  static var stringArray: Self { Sdf.getValueType(for: .stringArray) }
  static var tokenArray: Self { Sdf.getValueType(for: .tokenArray) }
  static var assetArray: Self { Sdf.getValueType(for: .assetArray) }

  static var int2Array: Self { Sdf.getValueType(for: .int2Array) }
  static var int3Array: Self { Sdf.getValueType(for: .int3Array) }
  static var int4Array: Self { Sdf.getValueType(for: .int4Array) }
  static var half2Array: Self { Sdf.getValueType(for: .half2Array) }
  static var half3Array: Self { Sdf.getValueType(for: .half3Array) }
  static var half4Array: Self { Sdf.getValueType(for: .half4Array) }
  static var float2Array: Self { Sdf.getValueType(for: .float2Array) }
  static var float3Array: Self { Sdf.getValueType(for: .float3Array) }
  static var float4Array: Self { Sdf.getValueType(for: .float4Array) }
  static var double2Array: Self { Sdf.getValueType(for: .double2Array) }
  static var double3Array: Self { Sdf.getValueType(for: .double3Array) }
  static var double4Array: Self { Sdf.getValueType(for: .double4Array) }

  static var point3hArray: Self { Sdf.getValueType(for: .point3hArray) }
  static var point3fArray: Self { Sdf.getValueType(for: .point3fArray) }
  static var point3dArray: Self { Sdf.getValueType(for: .point3dArray) }
  static var vector3hArray: Self { Sdf.getValueType(for: .vector3hArray) }
  static var vector3fArray: Self { Sdf.getValueType(for: .vector3fArray) }
  static var vector3dArray: Self { Sdf.getValueType(for: .vector3dArray) }
  static var normal3hArray: Self { Sdf.getValueType(for: .normal3hArray) }
  static var normal3fArray: Self { Sdf.getValueType(for: .normal3fArray) }
  static var normal3dArray: Self { Sdf.getValueType(for: .normal3dArray) }
  static var color3hArray: Self { Sdf.getValueType(for: .color3hArray) }
  static var color3fArray: Self { Sdf.getValueType(for: .color3fArray) }
  static var color3dArray: Self { Sdf.getValueType(for: .color3dArray) }
  static var color4hArray: Self { Sdf.getValueType(for: .color4hArray) }
  static var color4fArray: Self { Sdf.getValueType(for: .color4fArray) }
  static var color4dArray: Self { Sdf.getValueType(for: .color4dArray) }

  static var quathArray: Self { Sdf.getValueType(for: .quathArray) }
  static var quatfArray: Self { Sdf.getValueType(for: .quatfArray) }
  static var quatdArray: Self { Sdf.getValueType(for: .quatdArray) }

  static var matrix2dArray: Self { Sdf.getValueType(for: .matrix2dArray) }
  static var matrix3dArray: Self { Sdf.getValueType(for: .matrix3dArray) }
  static var matrix4dArray: Self { Sdf.getValueType(for: .matrix4dArray) }
  static var frame4dArray: Self { Sdf.getValueType(for: .frame4dArray) }

  static var texCoord2hArray: Self { Sdf.getValueType(for: .texCoord2hArray) }
  static var texCoord2fArray: Self { Sdf.getValueType(for: .texCoord2fArray) }
  static var texCoord2dArray: Self { Sdf.getValueType(for: .texCoord2dArray) }
  static var texCoord3hArray: Self { Sdf.getValueType(for: .texCoord3hArray) }
  static var texCoord3fArray: Self { Sdf.getValueType(for: .texCoord3fArray) }
  static var texCoord3dArray: Self { Sdf.getValueType(for: .texCoord3dArray) }

  static var pathExpressionArray: Self { Sdf.getValueType(for: .pathExpressionArray) }
}

#if !canImport(Sdf)
public extension Pixar
{
  enum SdfValueTypeNameType
  {
    case bool, uChar, int, uInt, int64, uInt64
    case half, float, double, timeCode
    case string, token, asset
    case int2, int3, int4
    case half2, half3, half4
    case float2, float3, float4
    case double2, double3, double4
    case point3h, point3f, point3d
    case vector3h, vector3f, vector3d
    case normal3h, normal3f, normal3d
    case color3h, color3f, color3d
    case color4h, color4f, color4d
    case quath, quatf, quatd
    case matrix2d, matrix3d, matrix4d
    case frame4d
    case texCoord2h, texCoord2f, texCoord2d
    case texCoord3h, texCoord3f, texCoord3d
    case opaque, group, pathExpression

    case boolArray, uCharArray, intArray, uIntArray, int64Array, uInt64Array
    case halfArray, floatArray, doubleArray, timeCodeArray
    case stringArray, tokenArray, assetArray
    case int2Array, int3Array, int4Array
    case half2Array, half3Array, half4Array
    case float2Array, float3Array, float4Array
    case double2Array, double3Array, double4Array
    case point3hArray, point3fArray, point3dArray
    case vector3hArray, vector3fArray, vector3dArray
    case normal3hArray, normal3fArray, normal3dArray
    case color3hArray, color3fArray, color3dArray
    case color4hArray, color4fArray, color4dArray
    case quathArray, quatfArray, quatdArray
    case matrix2dArray, matrix3dArray, matrix4dArray
    case frame4dArray
    case texCoord2hArray, texCoord2fArray, texCoord2dArray
    case texCoord3hArray, texCoord3fArray, texCoord3dArray
    case pathExpressionArray
  }
}

extension Overlay
{
  public static func SdfGetValueTypeNameValue(_ type: Pixar.SdfValueTypeNameType) -> Pixar.SdfValueTypeName
  {
    Overlay.SdfGetValueTypeName(type)
  }
  
  public static func SdfGetValueTypeName(_ type: Pixar.SdfValueTypeNameType) -> Pixar.SdfValueTypeName
  {
    switch type {
      case .bool:                return Overlay.SdfValueTypeNames.Bool
      case .uChar:               return Overlay.SdfValueTypeNames.UChar
      case .int:                 return Overlay.SdfValueTypeNames.Int
      case .uInt:                return Overlay.SdfValueTypeNames.UInt
      case .int64:               return Overlay.SdfValueTypeNames.Int64
      case .uInt64:              return Overlay.SdfValueTypeNames.UInt64
      case .half:                return Overlay.SdfValueTypeNames.Half
      case .float:               return Overlay.SdfValueTypeNames.Float
      case .double:              return Overlay.SdfValueTypeNames.Double
      case .timeCode:            return Overlay.SdfValueTypeNames.TimeCode
      case .string:              return Overlay.SdfValueTypeNames.String
      case .token:               return Overlay.SdfValueTypeNames.Token
      case .asset:               return Overlay.SdfValueTypeNames.Asset
      case .int2:                return Overlay.SdfValueTypeNames.Int2
      case .int3:                return Overlay.SdfValueTypeNames.Int3
      case .int4:                return Overlay.SdfValueTypeNames.Int4
      case .half2:               return Overlay.SdfValueTypeNames.Half2
      case .half3:               return Overlay.SdfValueTypeNames.Half3
      case .half4:               return Overlay.SdfValueTypeNames.Half4
      case .float2:              return Overlay.SdfValueTypeNames.Float2
      case .float3:              return Overlay.SdfValueTypeNames.Float3
      case .float4:              return Overlay.SdfValueTypeNames.Float4
      case .double2:             return Overlay.SdfValueTypeNames.Double2
      case .double3:             return Overlay.SdfValueTypeNames.Double3
      case .double4:             return Overlay.SdfValueTypeNames.Double4
      case .point3h:             return Overlay.SdfValueTypeNames.Point3h
      case .point3f:             return Overlay.SdfValueTypeNames.Point3f
      case .point3d:             return Overlay.SdfValueTypeNames.Point3d
      case .vector3h:            return Overlay.SdfValueTypeNames.Vector3h
      case .vector3f:            return Overlay.SdfValueTypeNames.Vector3f
      case .vector3d:            return Overlay.SdfValueTypeNames.Vector3d
      case .normal3h:            return Overlay.SdfValueTypeNames.Normal3h
      case .normal3f:            return Overlay.SdfValueTypeNames.Normal3f
      case .normal3d:            return Overlay.SdfValueTypeNames.Normal3d
      case .color3h:             return Overlay.SdfValueTypeNames.Color3h
      case .color3f:             return Overlay.SdfValueTypeNames.Color3f
      case .color3d:             return Overlay.SdfValueTypeNames.Color3d
      case .color4h:             return Overlay.SdfValueTypeNames.Color4h
      case .color4f:             return Overlay.SdfValueTypeNames.Color4f
      case .color4d:             return Overlay.SdfValueTypeNames.Color4d
      case .quath:               return Overlay.SdfValueTypeNames.Quath
      case .quatf:               return Overlay.SdfValueTypeNames.Quatf
      case .quatd:               return Overlay.SdfValueTypeNames.Quatd
      case .matrix2d:            return Overlay.SdfValueTypeNames.Matrix2d
      case .matrix3d:            return Overlay.SdfValueTypeNames.Matrix3d
      case .matrix4d:            return Overlay.SdfValueTypeNames.Matrix4d
      case .frame4d:             return Overlay.SdfValueTypeNames.Frame4d
      case .texCoord2h:          return Overlay.SdfValueTypeNames.TexCoord2h
      case .texCoord2f:          return Overlay.SdfValueTypeNames.TexCoord2f
      case .texCoord2d:          return Overlay.SdfValueTypeNames.TexCoord2d
      case .texCoord3h:          return Overlay.SdfValueTypeNames.TexCoord3h
      case .texCoord3f:          return Overlay.SdfValueTypeNames.TexCoord3f
      case .texCoord3d:          return Overlay.SdfValueTypeNames.TexCoord3d
      case .opaque:              return Overlay.SdfValueTypeNames.Opaque
      case .group:               return Overlay.SdfValueTypeNames.Group
      case .pathExpression:      return Overlay.SdfValueTypeNames.PathExpression
      case .boolArray:           return Overlay.SdfValueTypeNames.BoolArray
      case .uCharArray:          return Overlay.SdfValueTypeNames.UCharArray
      case .intArray:            return Overlay.SdfValueTypeNames.IntArray
      case .uIntArray:           return Overlay.SdfValueTypeNames.UIntArray
      case .int64Array:          return Overlay.SdfValueTypeNames.Int64Array
      case .uInt64Array:         return Overlay.SdfValueTypeNames.UInt64Array
      case .halfArray:           return Overlay.SdfValueTypeNames.HalfArray
      case .floatArray:          return Overlay.SdfValueTypeNames.FloatArray
      case .doubleArray:         return Overlay.SdfValueTypeNames.DoubleArray
      case .timeCodeArray:       return Overlay.SdfValueTypeNames.TimeCodeArray
      case .stringArray:         return Overlay.SdfValueTypeNames.StringArray
      case .tokenArray:          return Overlay.SdfValueTypeNames.TokenArray
      case .assetArray:          return Overlay.SdfValueTypeNames.AssetArray
      case .int2Array:           return Overlay.SdfValueTypeNames.Int2Array
      case .int3Array:           return Overlay.SdfValueTypeNames.Int3Array
      case .int4Array:           return Overlay.SdfValueTypeNames.Int4Array
      case .half2Array:          return Overlay.SdfValueTypeNames.Half2Array
      case .half3Array:          return Overlay.SdfValueTypeNames.Half3Array
      case .half4Array:          return Overlay.SdfValueTypeNames.Half4Array
      case .float2Array:         return Overlay.SdfValueTypeNames.Float2Array
      case .float3Array:         return Overlay.SdfValueTypeNames.Float3Array
      case .float4Array:         return Overlay.SdfValueTypeNames.Float4Array
      case .double2Array:        return Overlay.SdfValueTypeNames.Double2Array
      case .double3Array:        return Overlay.SdfValueTypeNames.Double3Array
      case .double4Array:        return Overlay.SdfValueTypeNames.Double4Array
      case .point3hArray:        return Overlay.SdfValueTypeNames.Point3hArray
      case .point3fArray:        return Overlay.SdfValueTypeNames.Point3fArray
      case .point3dArray:        return Overlay.SdfValueTypeNames.Point3dArray
      case .vector3hArray:       return Overlay.SdfValueTypeNames.Vector3hArray
      case .vector3fArray:       return Overlay.SdfValueTypeNames.Vector3fArray
      case .vector3dArray:       return Overlay.SdfValueTypeNames.Vector3dArray
      case .normal3hArray:       return Overlay.SdfValueTypeNames.Normal3hArray
      case .normal3fArray:       return Overlay.SdfValueTypeNames.Normal3fArray
      case .normal3dArray:       return Overlay.SdfValueTypeNames.Normal3dArray
      case .color3hArray:        return Overlay.SdfValueTypeNames.Color3hArray
      case .color3fArray:        return Overlay.SdfValueTypeNames.Color3fArray
      case .color3dArray:        return Overlay.SdfValueTypeNames.Color3dArray
      case .color4hArray:        return Overlay.SdfValueTypeNames.Color4hArray
      case .color4fArray:        return Overlay.SdfValueTypeNames.Color4fArray
      case .color4dArray:        return Overlay.SdfValueTypeNames.Color4dArray
      case .quathArray:          return Overlay.SdfValueTypeNames.QuathArray
      case .quatfArray:          return Overlay.SdfValueTypeNames.QuatfArray
      case .quatdArray:          return Overlay.SdfValueTypeNames.QuatdArray
      case .matrix2dArray:       return Overlay.SdfValueTypeNames.Matrix2dArray
      case .matrix3dArray:       return Overlay.SdfValueTypeNames.Matrix3dArray
      case .matrix4dArray:       return Overlay.SdfValueTypeNames.Matrix4dArray
      case .frame4dArray:        return Overlay.SdfValueTypeNames.Frame4dArray
      case .texCoord2hArray:     return Overlay.SdfValueTypeNames.TexCoord2hArray
      case .texCoord2fArray:     return Overlay.SdfValueTypeNames.TexCoord2fArray
      case .texCoord2dArray:     return Overlay.SdfValueTypeNames.TexCoord2dArray
      case .texCoord3hArray:     return Overlay.SdfValueTypeNames.TexCoord3hArray
      case .texCoord3fArray:     return Overlay.SdfValueTypeNames.TexCoord3fArray
      case .texCoord3dArray:     return Overlay.SdfValueTypeNames.TexCoord3dArray
      case .pathExpressionArray: return Overlay.SdfValueTypeNames.PathExpressionArray
      default:                   return Overlay.SdfValueTypeNames.Bool
    }
  }
}
#endif
