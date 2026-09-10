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

#if canImport(UsdGeom)
  import UsdGeom
#else
  import OpenUSD
#endif

private extension UsdGeom
{
  /**
   * Private struct to hold the static
   * data for the UsdGeom library. */
  struct StaticData: @unchecked Sendable
  {
    static let shared = StaticData()
    private init()
    {}

    let tokens = Pixar.UsdGeomTokensType()
  }
}

public extension UsdGeom
{
  /**
   * # UsdGeom.Tokens
   *
   * ## Overview
   *
   * Public, client facing api to access
   * the static UsdGeom tokens. */
  enum Tokens: CaseIterable
  {
    case basisCurves
    case hermiteCurves
    case nurbsCurves
    case nurbsPatch
    case boundable
    case imageable
    case mesh
    case pointBased
    case pointInstancer
    case points
    case plane
    case camera
    case capsule
    case cone
    case cube
    case curves
    case cylinder
    case sphere
    case scope
    case geomSubset
    case gprim
    case xform
    case xformable
    case xformCommonAPI
    case motionAPI
    case primvarsAPI
    case geomModelAPI
    case visibilityAPI
    case x
    case y
    case z
    case default_
    case proxy
    case render

    public var token: Tf.Token
    {
      switch self
      {
        case .basisCurves: StaticData.shared.tokens.BasisCurves
        case .hermiteCurves: StaticData.shared.tokens.HermiteCurves
        case .nurbsCurves: StaticData.shared.tokens.NurbsCurves
        case .nurbsPatch: StaticData.shared.tokens.NurbsPatch
        case .boundable: StaticData.shared.tokens.Boundable
        case .imageable: StaticData.shared.tokens.Imageable
        case .mesh: StaticData.shared.tokens.Mesh
        case .pointBased: StaticData.shared.tokens.PointBased
        case .pointInstancer: StaticData.shared.tokens.PointInstancer
        case .points: StaticData.shared.tokens.Points
        case .plane: StaticData.shared.tokens.Plane
        case .camera: StaticData.shared.tokens.Camera
        case .capsule: StaticData.shared.tokens.Capsule
        case .cone: StaticData.shared.tokens.Cone
        case .cube: StaticData.shared.tokens.Cube
        case .curves: StaticData.shared.tokens.Curves
        case .cylinder: StaticData.shared.tokens.Cylinder
        case .sphere: StaticData.shared.tokens.Sphere
        case .scope: StaticData.shared.tokens.Scope
        case .geomSubset: StaticData.shared.tokens.GeomSubset
        case .gprim: StaticData.shared.tokens.Gprim
        case .xform: StaticData.shared.tokens.Xform
        case .xformable: StaticData.shared.tokens.Xformable
        case .xformCommonAPI: StaticData.shared.tokens.XformCommonAPI
        case .motionAPI: StaticData.shared.tokens.MotionAPI
        case .primvarsAPI: StaticData.shared.tokens.PrimvarsAPI
        case .geomModelAPI: StaticData.shared.tokens.GeomModelAPI
        case .visibilityAPI: StaticData.shared.tokens.VisibilityAPI
        case .x: StaticData.shared.tokens.x
        case .y: StaticData.shared.tokens.y
        case .z: StaticData.shared.tokens.z
        case .default_: StaticData.shared.tokens.default_
        case .proxy: StaticData.shared.tokens.proxy
        case .render: StaticData.shared.tokens.render
      }
    }
  }
}

public extension Tf.Token
{
  nonisolated(unsafe) static let x = UsdGeom.Tokens.x.token
  nonisolated(unsafe) static let y = UsdGeom.Tokens.y.token
  nonisolated(unsafe) static let z = UsdGeom.Tokens.z.token
}
