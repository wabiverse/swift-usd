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
    case faceVarying
    case constant
    case none_
    case normals
    case invisible
    case inherited
    case visibility
    case purpose
    case guide
    case perspective
    case orthographic
    case projection
    case focalLength
    case horizontalAperture
    case verticalAperture
    case horizontalApertureOffset
    case verticalApertureOffset
    case clippingRange
    case fStop
    case focusDistance
    case radius
    case linear

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
        case .faceVarying: StaticData.shared.tokens.faceVarying
        case .constant: StaticData.shared.tokens.constant
        case .none_: StaticData.shared.tokens.none
        case .normals: StaticData.shared.tokens.normals
        case .invisible: StaticData.shared.tokens.invisible
        case .inherited: StaticData.shared.tokens.inherited
        case .visibility: StaticData.shared.tokens.visibility
        case .purpose: StaticData.shared.tokens.purpose
        case .guide: StaticData.shared.tokens.guide
        case .perspective: StaticData.shared.tokens.perspective
        case .orthographic: StaticData.shared.tokens.orthographic
        case .projection: StaticData.shared.tokens.projection
        case .focalLength: StaticData.shared.tokens.focalLength
        case .horizontalAperture: StaticData.shared.tokens.horizontalAperture
        case .verticalAperture: StaticData.shared.tokens.verticalAperture
        case .horizontalApertureOffset: StaticData.shared.tokens.horizontalApertureOffset
        case .verticalApertureOffset: StaticData.shared.tokens.verticalApertureOffset
        case .clippingRange: StaticData.shared.tokens.clippingRange
        case .fStop: StaticData.shared.tokens.fStop
        case .focusDistance: StaticData.shared.tokens.focusDistance
        case .radius: StaticData.shared.tokens.radius
        case .linear: StaticData.shared.tokens.linear
      }
    }
  }
}

public extension Tf.Token
{
  nonisolated(unsafe) static let basisCurves = UsdGeom.Tokens.basisCurves.token
  nonisolated(unsafe) static let hermiteCurves = UsdGeom.Tokens.hermiteCurves.token
  nonisolated(unsafe) static let nurbsCurves = UsdGeom.Tokens.nurbsCurves.token
  nonisolated(unsafe) static let nurbsPatch = UsdGeom.Tokens.nurbsPatch.token
  nonisolated(unsafe) static let boundable = UsdGeom.Tokens.boundable.token
  nonisolated(unsafe) static let imageable = UsdGeom.Tokens.imageable.token
  nonisolated(unsafe) static let mesh = UsdGeom.Tokens.mesh.token
  nonisolated(unsafe) static let pointBased = UsdGeom.Tokens.pointBased.token
  nonisolated(unsafe) static let pointInstancer = UsdGeom.Tokens.pointInstancer.token
  nonisolated(unsafe) static let points = UsdGeom.Tokens.points.token
  nonisolated(unsafe) static let plane = UsdGeom.Tokens.plane.token
  nonisolated(unsafe) static let camera = UsdGeom.Tokens.camera.token
  nonisolated(unsafe) static let capsule = UsdGeom.Tokens.capsule.token
  nonisolated(unsafe) static let cone = UsdGeom.Tokens.cone.token
  nonisolated(unsafe) static let cube = UsdGeom.Tokens.cube.token
  nonisolated(unsafe) static let curves = UsdGeom.Tokens.curves.token
  nonisolated(unsafe) static let cylinder = UsdGeom.Tokens.cylinder.token
  nonisolated(unsafe) static let sphere = UsdGeom.Tokens.sphere.token
  nonisolated(unsafe) static let scope = UsdGeom.Tokens.scope.token
  nonisolated(unsafe) static let geomSubset = UsdGeom.Tokens.geomSubset.token
  nonisolated(unsafe) static let gprim = UsdGeom.Tokens.gprim.token
  nonisolated(unsafe) static let xform = UsdGeom.Tokens.xform.token
  nonisolated(unsafe) static let xformable = UsdGeom.Tokens.xformable.token
  nonisolated(unsafe) static let xformCommonAPI = UsdGeom.Tokens.xformCommonAPI.token
  nonisolated(unsafe) static let motionAPI = UsdGeom.Tokens.motionAPI.token
  nonisolated(unsafe) static let primvarsAPI = UsdGeom.Tokens.primvarsAPI.token
  nonisolated(unsafe) static let geomModelAPI = UsdGeom.Tokens.geomModelAPI.token
  nonisolated(unsafe) static let visibilityAPI = UsdGeom.Tokens.visibilityAPI.token

  nonisolated(unsafe) static let x = UsdGeom.Tokens.x.token
  nonisolated(unsafe) static let y = UsdGeom.Tokens.y.token
  nonisolated(unsafe) static let z = UsdGeom.Tokens.z.token
  
  nonisolated(unsafe) static let default_ = UsdGeom.Tokens.default_.token
  nonisolated(unsafe) static let proxy = UsdGeom.Tokens.proxy.token
  nonisolated(unsafe) static let render = UsdGeom.Tokens.render.token

  nonisolated(unsafe) static let faceVarying = UsdGeom.Tokens.faceVarying.token
  nonisolated(unsafe) static let constant = UsdGeom.Tokens.constant.token
  nonisolated(unsafe) static let none_ = UsdGeom.Tokens.none_.token
  nonisolated(unsafe) static let normals = UsdGeom.Tokens.normals.token
  nonisolated(unsafe) static let invisible = UsdGeom.Tokens.invisible.token
  nonisolated(unsafe) static let inherited = UsdGeom.Tokens.inherited.token
  nonisolated(unsafe) static let visibility = UsdGeom.Tokens.visibility.token
  nonisolated(unsafe) static let purpose = UsdGeom.Tokens.purpose.token
  nonisolated(unsafe) static let guide = UsdGeom.Tokens.guide.token
  nonisolated(unsafe) static let perspective = UsdGeom.Tokens.perspective.token
  nonisolated(unsafe) static let orthographic = UsdGeom.Tokens.orthographic.token
  nonisolated(unsafe) static let projection = UsdGeom.Tokens.projection.token
  nonisolated(unsafe) static let focalLength = UsdGeom.Tokens.focalLength.token
  nonisolated(unsafe) static let horizontalAperture = UsdGeom.Tokens.horizontalAperture.token
  nonisolated(unsafe) static let verticalAperture = UsdGeom.Tokens.verticalAperture.token
  nonisolated(unsafe) static let horizontalApertureOffset = UsdGeom.Tokens.horizontalApertureOffset.token
  nonisolated(unsafe) static let verticalApertureOffset = UsdGeom.Tokens.verticalApertureOffset.token
  nonisolated(unsafe) static let clippingRange = UsdGeom.Tokens.clippingRange.token
  nonisolated(unsafe) static let fStop = UsdGeom.Tokens.fStop.token
  nonisolated(unsafe) static let focusDistance = UsdGeom.Tokens.focusDistance.token
  nonisolated(unsafe) static let radius = UsdGeom.Tokens.radius.token
  nonisolated(unsafe) static let linear = UsdGeom.Tokens.linear.token
}
