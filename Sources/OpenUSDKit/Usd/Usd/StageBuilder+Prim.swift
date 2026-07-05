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

import Foundation
#if canImport(Usd)
  import Usd
#else
  import OpenUSD
#endif

public protocol Prim
{
  var path: Sdf.Path { get }

  var name: Tf.Token { get }

  var children: [any Prim] { get }
  
  var typeName: Tf.Token { get }
  
  var attributes: Pixar.UsdAttributeVector { get }
  
  var authoredAttributes: Pixar.UsdAttributeVector { get }
  
  func isActive() -> Bool
  
  func set(active: Bool)
  
  func set(doc: String)
  
  func createAttribute(name: Tf.Token,
                       typeName: Sdf.ValueTypeName,
                       custom: Bool,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(name: String,
                       typeName: Sdf.ValueTypeNameType,
                       custom: Bool,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(name: Tf.Token,
                       typeName: Sdf.ValueTypeName,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(name: String,
                       typeName: Sdf.ValueTypeNameType,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(nameComponents: Overlay.String_Vector,
                       typeName: Sdf.ValueTypeName,
                       custom: Bool,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(nameComponents: Overlay.String_Vector,
                       typeName: Sdf.ValueTypeNameType,
                       custom: Bool,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(nameComponents: Overlay.String_Vector,
                       typeName: Sdf.ValueTypeName,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func createAttribute(nameComponents: Overlay.String_Vector,
                       typeName: Sdf.ValueTypeNameType,
                       variability: Sdf.Variability) -> Usd.Attribute?
  
  func attribute(named name: Tf.Token) -> Usd.Attribute?
  
  func attribute(named name: String) -> Usd.Attribute?
  
  func hasAttribute(named name: Tf.Token) -> Bool
  
  func hasAttribute(named name: String) -> Bool
  
  func findAllAttributeConnectionPaths(traversalPredicate: Pixar.Usd_PrimFlagsPredicate,
                                       recurseOnSources: Bool) -> Pixar.SdfPathVector
  
  func findAllAttributeConnectionPaths(recurseOnSources: Bool) -> Pixar.SdfPathVector
}

/**
 * A ``Usd/Prim`` for declaratively authoring scene description
 * on a ``USDStage``. */
public struct USDPrim
{
  public var path: Sdf.Path
  public var type: PrimType
  public var children: [USDPrim]

  public init(_ path: String, type: PrimType = .token(Tf.Token()), @StageBuilder children: () -> [USDPrim] = { [] })
  {
    self.path = Sdf.Path("/\(path)")
    self.type = type
    self.children = children()
  }
}

extension USDPrim: Equatable
{
  public static func == (lhs: USDPrim, rhs: USDPrim) -> Bool
  {
    lhs.path.string == rhs.path.string
  }
}

public extension USDPrim
{
  enum PrimType
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
    case distantLight
    case diskLight
    case rectLight
    case sphereLight
    case cylinderLight
    case geometryLight
    case domeLight
    case portalLight
    case xform
    case xformable
    case xformCommonAPI
    case lightAPI
    case meshLightAPI
    case volumeLightAPI
    case motionAPI
    case primvarsAPI
    case geomModelAPI
    case visibilityAPI
    case token(Tf.Token)
    case group([USDPrim])
  }
}
