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
import Foundation
#if canImport(Usd)
  import Usd
#else
  import OpenUSD
#endif

public typealias UsdStageWeakPtr = Pixar.UsdStageWeakPtr
public typealias UsdPrim = Pixar.UsdPrim

public typealias Usd_PrimFlagsPredicate = Pixar.Usd_PrimFlagsPredicate

public extension Usd
{
  /**
   * # Usd.Prim
   *
   * ``Prim`` is the sole persistent scenegraph object on a UsdStage, and
   * is the embodiment of a "Prim" as described in the *Universal Scene
   * Description Composition Compendium*.
   *
   * A ``Prim`` is the principal container of other types of scene description.
   * It provides API for accessing and creating all of the contained kinds of scene
   * description, which include:
   * - ``VariantSets`` - all VariantSets on the prim (`getVariantSets()`, `getVariantSet()`).
   * - ``References`` - all references on the prim (`getReferences()`).
   * - ``Inherits`` - all inherits on the prim (`getInherits()`).
   * - ``Specializes`` - all specializes on the prim (`getSpecializes()`).
   *
   * As well as access to the API objects for properties contained within the prim - ``Prim``
   * as well as all of the following classes are subclasses of ``Object``:
   * - ``Property`` - generic access to all attributes and relationships.
   * A ``Property`` can be queried and cast to a ``Usd.Attribute`` or
   * - ``Relationship`` using ``Object/is<T>(a: T.self)`` and ``Object/as<T>(T.self)``.
   * (getPropertyNames(), getProperties(), getPropertiesInNamespace(), getPropertyOrder(), setPropertyOrder()).
   * - ``Attribute`` - access to default and timesampled attribute values, as well as value resolution information,
   * and attribute-specific metadata (createAttribute(), getAttribute(), getAttributes(), hasAttribute()).
   * - ``Relationship`` - access to authoring and resolving relationships to other prims and properties
   * (createRelationship(), getRelationship(), getRelationships(), hasRelationship()).
   *
   * ``Prim`` also provides access to iteration through its prim children,
   * optionally making use of the **Prim Predicates Facility** (getChildren(),
   * getAllChildren(), getFilteredChildren()).
   *
   * ### Lifetime Management
   *
   * Clients acquire UsdPrim objects, which act like weak/guarded pointers
   * to persistent objects owned and managed by their originating UsdStage.
   *
   * We provide the following guarantees for a UsdPrim acquired via any of
   * the following:
   *
   * - ``__ObjC/Pixar/TfRefPtr<UsdStage>/getPrim(at:)-1jtte``
   * - ``__ObjC/Pixar/TfRefPtr<UsdStage>/overridePrim(path:)-3liu9``
   * - ``__ObjC/Pixar/TfRefPtr<UsdStage>/definePrim(_:type:)-19ehc``
   *
   *   - As long as no further mutations to the structure of the UsdStage
   *   are made, the UsdPrim will still be valid. Loading and unloading are
   *   considered structural mutations.
   *
   *   - When the ``Stage``'s structure is **mutated**, the thread performing
   *   the mutation will receive a ``Notice/objectsChanged`` notice after the
   *   stage has been reconfigured, which provides details as to what prims may
   *   have been created or destroyed, and what prims may simply have changed in
   *   some structural way.
   *
   * Prim access in "reader" threads should be limited to
   * ``__ObjC/Pixar/TfRefPtr<UsdStage>/getPrim(at:)-1jtte``,
   * which will never cause a mutation to the Stage or its layers.
   *
   * Please refer to ``Notice`` for a listing of the events that could cause
   * ``Notice/objectsChanged`` to be emitted.
   */
  typealias Prim = UsdPrim
  typealias StageWeakPtr = UsdStageWeakPtr

  typealias PrimFlagsPredicate = Usd_PrimFlagsPredicate
}

#if canImport(Usd)
extension Usd.Prim: Hashable
{
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  public static func == (lhs: Pixar.UsdPrim, rhs: Pixar.UsdPrim) -> Bool
  {
    lhs.name == rhs.name
  }
}
#endif

extension Usd.Prim: Prim
{
  /**
   * Sets the documentation string for this layer. */
  public func set(doc: String)
  {
    doc.withCString { Overlay.SetDocumentation(self, $0) }
  }

  public func set(active: Bool)
  {
    SetActive(active)
  }

  public func isActive() -> Bool
  {
    IsActive()
  }
  
  public func getStage() -> UsdStageWeakPtr
  {
    GetStage()
  }

  public func getPath() -> Sdf.Path
  {
    GetPath()
  }

  public func getReferences() -> Usd.References
  {
    GetReferences()
  }

#if canImport(Usd)
  private borrowing func GetNameCopy() -> Tf.Token
  {
    __GetNameUnsafe().pointee
  }

  private borrowing func GetTypeNameCopy() -> Tf.Token
  {
    __GetTypeNameUnsafe().pointee
  }
#endif

  public var path: Sdf.Path
  {
    GetPath()
  }

  public var name: Tf.Token
  {
    #if canImport(Usd)
      GetNameCopy()
    #else
      GetName()
    #endif
  }

  public var typeName: Tf.Token
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

  public var children: [any Prim]
  {
    IteratorSequence(GetChildren()).map { $0 }
  }
  
  /// Author scene description for the attribute named \a attrName at the
  /// current EditTarget if none already exists.  Return a valid attribute if
  /// scene description was successfully authored or if it already existed,
  /// return invalid attribute otherwise.  Note that the supplied \a typeName
  /// and \a custom arguments are only used in one specific case.  See below
  /// for details.
  ///
  /// Suggested use:
  /// ```swift
  /// if let myAttr = prim.createAttribute(...) {
  ///   // success.
  /// }
  /// ```
  ///
  /// To call this, GetPrim() must return a valid prim.
  ///
  /// - If a spec for this attribute already exists at the current edit
  /// target, do nothing.
  ///
  /// - If a spec for \a attrName of a different spec type (e.g. a
  /// relationship) exists at the current EditTarget, issue an error.
  ///
  /// - If \a name refers to a builtin attribute according to the prim's
  /// definition, author an attribute spec with required metadata from the
  /// definition.
  ///
  /// - If \a name refers to a builtin relationship, issue an error.
  ///
  /// - If there exists an absolute strongest authored attribute spec for
  /// \a attrName, author an attribute spec at the current EditTarget by
  /// copying required metadata from that strongest spec.
  ///
  /// - If there exists an absolute strongest authored relationship spec for
  /// \a attrName, issue an error.
  ///
  /// - Otherwise author an attribute spec at the current EditTarget using
  /// the provided \a typeName and \a custom for the required metadata fields.
  /// Note that these supplied arguments are only ever used in this particular
  /// circumstance, in all other cases they are ignored.
  @discardableResult
  public func createAttribute(name: Tf.Token,
                              typeName: Sdf.ValueTypeName,
                              custom: Bool,
                              variability: Sdf.Variability = .varying) -> Usd.Attribute?
  {
    CreateAttribute(name, typeName, custom, variability).validOrNil
  }
  
  /// \overload
  /// Create a custom attribute with \p name, \p typeName and \p variability.
  @discardableResult
  public func createAttribute(name: Tf.Token,
                              typeName: Sdf.ValueTypeName,
                              variability: Sdf.Variability = .varying) -> Usd.Attribute?
  {
    CreateAttribute(name, typeName, variability).validOrNil
  }
  
  /// \overload
  /// This overload of CreateAttribute() accepts a vector of name components
  /// used to construct a \em namespaced property name.  For details, see
  /// \ref Usd_Ordering
  @discardableResult
  public func createAttribute(nameComponents: Overlay.String_Vector,
                              typeName: Sdf.ValueTypeName,
                              custom: Bool,
                              variability: Sdf.Variability = .varying) -> Usd.Attribute?
  {
    CreateAttribute(nameComponents, typeName, custom, variability).validOrNil
  }
  
  /// \overload
  /// Create a custom attribute with \p nameComponents, \p typeName, and \p variability.
  @discardableResult
  public func createAttribute(nameComponents: Overlay.String_Vector,
                              typeName: Sdf.ValueTypeName,
                              variability: Sdf.Variability = .varying) -> Usd.Attribute?
  {
    CreateAttribute(nameComponents, typeName, variability).validOrNil
  }
  
  /// Like GetProperties(), but exclude all relationships from the result.
  public var attributes: Pixar.UsdAttributeVector
  {
    GetAttributes()
  }
  
  /// Like `attributes`, but exclude attributes without authored scene
  /// description from the result.  See `UsdProperty/IsAuthored()`.
  public var authoredAttributes: Pixar.UsdAttributeVector
  {
    GetAuthoredAttributes()
  }
  
  /// Return a UsdAttribute with the named \a name. The attribute
  /// returned may or may not \b actually exist so it must be checked for
  /// validity. Suggested use:
  ///
  /// ```swift
  /// if let myAttr = prim.attribute(named: Tf.Token("myAttr")) {
  ///   // myAttr is safe to use.
  ///   // Edits to the owning stage requires subsequent validation.
  /// } else {
  ///   // myAttr was not defined/authored
  /// }
  /// ```
  public func attribute(named name: Tf.Token) -> Usd.Attribute?
  {
    GetAttribute(name).validOrNil
  }
  
  /// Return a UsdAttribute with the named \a name. The attribute
  /// returned may or may not \b actually exist so it must be checked for
  /// validity. Suggested use:
  ///
  /// ```swift
  /// if let myAttr = prim.attribute(named: "myAttr") {
  ///   // myAttr is safe to use.
  ///   // Edits to the owning stage requires subsequent validation.
  /// } else {
  ///   // myAttr was not defined/authored
  /// }
  /// ```
  public func attribute(named name: String) -> Usd.Attribute?
  {
    GetAttribute(Tf.Token(name)).validOrNil
  }
  
  /// Return `true` if this prim has an attribute named \p name, `false`
  /// otherwise.
  public func hasAttribute(named name: Tf.Token) -> Bool
  {
    HasAttribute(name)
  }
  
  /// Search the prim subtree rooted at this prim according to \p traversalPredicate,
  /// collect their connection source paths and return them in an arbitrary order.  If
  /// \p recurseOnSources is true, act as if this function was invoked on the connected
  /// prims and owning prims of connected properties also and return the union.
  public func findAllAttributeConnectionPaths(traversalPredicate: Usd.PrimFlagsPredicate,
                                              recurseOnSources: Bool = false) -> Pixar.SdfPathVector
  {
    FindAllAttributeConnectionPaths(traversalPredicate, .init(), recurseOnSources)
  }
  
  @available(*, unavailable, renamed: "findAllAttributeConnectionPaths(traversalPredicate:recurseOnSources:)")
  public func findAllAttributeConnectionPaths(traversalPredicate: Usd.PrimFlagsPredicate,
                                              predicate: ((Usd.Attribute) -> Bool)?,
                                              recurseOnSources: Bool) -> Pixar.SdfPathVector
  {
    fatalError("This function is not yet supported. Use the version without the predicate parameter.")
  }
  
  /// \overload
  /// Invoke FindAllAttributeConnectionPaths() with the UsdPrimDefaultPredicate as its traversalPredicate.
  public func findAllAttributeConnectionPaths(recurseOnSources: Bool = false) -> Pixar.SdfPathVector
  {
    FindAllAttributeConnectionPaths(.init(), recurseOnSources)
  }
  
  @available(*, unavailable, renamed: "findAllAttributeConnectionPaths(recurseOnSources:)")
  public func findAllAttributeConnectionPaths(predicate: ((Usd.Attribute) -> Bool)?,
                                              recurseOnSources: Bool) -> Pixar.SdfPathVector
  {
    fatalError("This function is not yet supported. Use the version without the predicate parameter.")
  }
}

extension Pixar.Usd_PrimFlagsPredicate
{
  public static let active = Self(Pixar.Usd_PrimActiveFlag)
  public static let loaded = Self(Pixar.Usd_PrimLoadedFlag)
  public static let model = Self(Pixar.Usd_PrimModelFlag)
  public static let group = Self(Pixar.Usd_PrimGroupFlag)
  public static let abstract = Self(Pixar.Usd_PrimAbstractFlag)
  public static let defined = Self(Pixar.Usd_PrimDefinedFlag)
  public static let instance = Self(Pixar.Usd_PrimInstanceFlag)
  public static let classSpecifier = Self(Pixar.Usd_PrimHasClassSpecifierFlag)
  public static let definingSpecifier = Self(Pixar.Usd_PrimHasDefiningSpecifierFlag)

  public static let allPrims = Pixar.UsdPrimAllPrimsPredicate
  public static let defaultPredicate = Pixar.UsdPrimDefaultPredicate
}

#if !canImport(Usd)
extension Overlay
{
  public static func SetDocumentation(_ prim: Usd.Prim, _ doc: UnsafePointer<CChar>)
  {
    prim.SetDocumentation(std.string(doc))
  }
}
#endif

