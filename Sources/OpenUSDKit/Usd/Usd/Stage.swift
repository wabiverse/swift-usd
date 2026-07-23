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
  import Sdf
  import Usd
#else
  import OpenUSD
#endif

public typealias UsdStageRefPtr = Pixar.UsdStageRefPtr
public typealias UsdStage = Pixar.UsdStage

public extension Usd
{
  /**
   * # ``Stage``
   *
   * The outermost container for scene description, which owns and presents
   * composed prims as a scenegraph, following the composition recipe recursively
   * described in its associated "root layer".
   *
   * USD derives its persistent-storage scalability by combining and reusing simple
   * compositions into richer aggregates using referencing and layering with sparse
   * overrides. Ultimately, every composition (i.e. "scene") is identifiable by its
   * root layer, i.e. the `.usd` file, and a scene is instantiated in an application
   * on a Stage that presents a composed view of the scene's root layer. Each simple
   * composition referenced into a larger composition could be presented on its own
   * ``Stage``, at the same (or not) time that it is participating in the
   * larger composition on its own Stage; all of the underlying layers will be shared
   * by the two stages, while each maintains its own scenegraph of composed prims.
   *
   * A UsdStage has sole ownership over the ``Prim``'s with which it is
   * populated, and retains *shared* ownership (with other stages and direct clients
   * of ``Sdf/Layer``'s, via the ``Sdf/LayerRegistry``
   * that underlies all ``Sdf/Layer`` creation methods) of layers.
   *
   * It provides roughly five categories of API that address different aspects of scene
   * management:
   *
   * - "Stage lifetime management" methods for constructing and initially populating a
   * UsdStage from an existing layer file, or one that will be created as a result, in
   * memory or on the filesystem.
   * - "Load/unload working set management" methods that allow you to specify which
   * ``Payload``s should be included and excluded from the stage's composition.
   * - "Variant management" methods to manage policy for which variant to use when
   * composing prims that provide a named variant set, but do not specify a selection.
   * - "Prim access, creation, and mutation" methods that allow you to find, create, or
   * remove a prim identified by a path on
   * the stage. This group also provides methods for efficiently traversing the prims
   * on the stage.
   * - "Layers and EditTargets" methods provide access to the layers in the stage's
   * **root LayerStack** (i.e. the root layer and all of its recursive sublayers),
   * and the ability to set a ``EditTarget`` into which all subsequent
   * mutations to objects associated with the stage (e.g. prims, properties, etc)
   * will go.
   * - "Serialization" methods for "flattening" a composition (to varying degrees),
   * and exporting a completely flattened view of the stage to a string or file.
   * These methods can be very useful for targeted asset optimization and debugging,
   * though care should be exercized with large scenes, as flattening defeats some
   * of the benefits of referenced scene description, and may produce some very large
   * results, especially in file formats that do not support data de-duplication, like
   * the usda text format!
   *
   * ### Stage Session Layers
   *
   * Each ``Stage`` can possess an optional "session layer". The purpose
   * of a session layer is to hold ephemeral edits that modify a UsdStage's contents
   * or behavior in a way that is useful to the client, but should not be considered
   * as permanent mutations to be recorded upon export. A very common use of session
   * layers is to make variant selections, to pick a specific LOD or shading variation,
   * for example. The session layer is also frequently used to override the visibility
   * of geometry and assets in the scene. A session layer, if present, contributes to a
   * ``Stage``'s identity, for purposes of stage-caching, etc.
   *
   * To edit content in a session layer, get the layer's edit target using
   * `stage.getEditTarget(for: .localLayer, stage.getSessionLayer())` and
   * set that target in the stage by calling `setEditTarget()` or creating
   * a ``UsdEditContext``. */
  typealias Stage = Pixar.UsdStage
  typealias StageRefPtr = Pixar.UsdStageRefPtr
}

public extension Usd.Stage
{
  /**
   * ``InitialLoadingSet``
   *
   * ## Overview
   *
   * Specifies the initial set of prims
   * to load when opening a UsdStage. */
  enum InitialLoadingSet
  {
    case all
    case none

    public var rawValue: InitialLoadSet
    {
      switch self
      {
        case .all: InitialLoadSet(0)
        case .none: InitialLoadSet(1)
      }
    }
  }

  /**
   * Create a new stage with root layer `identifier`, destroying
   * potentially existing files with that identifier; it is considered an
   * error if an existing, open layer is present with this identifier.
   *
   * ``SdfLayer.CreateNew()``
   *
   * Invoking an overload that does not take a `sessionLayer`` argument will
   * create a stage with an anonymous in-memory session layer. To create a
   * stage without a session layer, pass TfNullPtr (or None in python) as the
   * `sessionLayer` argument.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. ``UsdStage.InitialLoadingSet``.
   *
   * If `pathResolverContext` is provided it will be bound when creating the
   * root layer at `identifier` and whenever asset path resolution is done
   * for this stage, regardless of what other context may be bound at that
   * time. Otherwise Usd will create the root layer with no context bound,
   * then create a context for all future asset path resolution for the stage
   * by calling ``ArResolver.createDefaultContextForAsset()`` with the root
   * layer's repository path if the layer has one, otherwise its resolved
   * path. */
  @discardableResult
  static func createNew(_ identifier: String, ext: USDStage.FileExt, load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      "\(identifier).\(ext.rawValue)".withCString { Overlay.CreateNewStage($0, load.rawValue) }
    )
  }

  /**
   * Create a new stage with root layer `identifier`, destroying
   * potentially existing files with that identifier; it is considered an
   * error if an existing, open layer is present with this identifier.
   *
   * ``SdfLayer.CreateNew()``
   *
   * Invoking an overload that does not take a `sessionLayer`` argument will
   * create a stage with an anonymous in-memory session layer. To create a
   * stage without a session layer, pass TfNullPtr (or None in python) as the
   * `sessionLayer` argument.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. ``UsdStage.InitialLoadingSet``.
   *
   * If `pathResolverContext` is provided it will be bound when creating the
   * root layer at `identifier` and whenever asset path resolution is done
   * for this stage, regardless of what other context may be bound at that
   * time. Otherwise Usd will create the root layer with no context bound,
   * then create a context for all future asset path resolution for the stage
   * by calling ``ArResolver.createDefaultContextForAsset()`` with the root
   * layer's repository path if the layer has one, otherwise its resolved
   * path. */
  @discardableResult
  static func createNew(_ identifier: String, load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      identifier.withCString { Overlay.CreateNewStage($0, load.rawValue) }
    )
  }

  /**
   * Creates a new stage only in memory, analogous to creating an anonymous
   * ``Pixar/Sdf/Layer``.
   *
   * If `pathResolverContext` is provided it will be bound when creating the
   * root layer at `identifier` and whenever asset path resolution is done
   * for this stage, regardless of what other context may be bound at that
   * time. Otherwise Usd will create the root layer with no context bound,
   * then create a context for all future asset path resolution for the stage
   * by calling ``ArResolver/createDefaultContext``.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. see ``InitialLoadingSet`` for more
   * options.
   *
   * Invoking an overload that does not take a `sessionLayer` argument will
   * create a stage with an anonymous in-memory session layer.  To create a
   * stage without a session layer, pass `Tf/NullPtr` (or None in python) as
   * the `sessionLayer` argument. */
  @discardableResult
  static func createInMemory(load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      Usd.Stage.CreateInMemory(load.rawValue)
    )
  }

  /**
   * Creates a new stage only in memory, analogous to creating an anonymous
   * ``Pixar/Sdf/Layer``.
   *
   * If `pathResolverContext` is provided it will be bound when creating the
   * root layer at `identifier` and whenever asset path resolution is done
   * for this stage, regardless of what other context may be bound at that
   * time. Otherwise Usd will create the root layer with no context bound,
   * then create a context for all future asset path resolution for the stage
   * by calling ``ArResolver/createDefaultContext``.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. see ``InitialLoadingSet`` for more
   * options.
   *
   * Invoking an overload that does not take a `sessionLayer` argument will
   * create a stage with an anonymous in-memory session layer.  To create a
   * stage without a session layer, pass `Tf/NullPtr` (or None in python) as
   * the `sessionLayer` argument. */
  @discardableResult
  static func createInMemory(_ identifier: String, load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      identifier.withCString { Overlay.CreateInMemoryStage($0, load.rawValue) }
    )
  }

  /**
   * Attempt to find a matching existing stage in a cache if
   * ``UsdStageCacheContext`` objects exist on the stack. Failing that, create
   * a new stage and recursively compose prims defined within and referenced by
   * the layer at `filePath`, which must already exist.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. see ``InitialLoadingSet`` for more
   * options.
   *
   * If `pathResolverContext` is provided it will be bound when opening the
   * root layer at `filePath` and whenever asset path resolution is done for
   * this stage, regardless of what other context may be bound at that time.
   * Otherwise Usd will open the root layer with no context bound, then create
   * a context for all future asset path resolution for the stage by calling
   * ``ArResolver.CreateDefaultContextForAsset()`` with the layer's repository
   * path if the layer has one, otherwise its resolved path. */
  @discardableResult
  static func open(_ filePath: String, load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      filePath.withCString { Overlay.OpenStage($0, load.rawValue) }
    )
  }

  /**
   * Attempt to find a matching existing stage in a cache if
   * ``UsdStageCacheContext`` objects exist on the stack. Failing that, create
   * a new stage and recursively compose prims defined within and referenced by
   * the layer at `filePath`, which must already exist.
   *
   * The initial set of prims to load on the stage can be specified
   * using the `load` parameter. see ``InitialLoadingSet`` for more
   * options.
   *
   * If `pathResolverContext` is provided it will be bound when opening the
   * root layer at `filePath` and whenever asset path resolution is done for
   * this stage, regardless of what other context may be bound at that time.
   * Otherwise Usd will open the root layer with no context bound, then create
   * a context for all future asset path resolution for the stage by calling
   * ``ArResolver.CreateDefaultContextForAsset()`` with the layer's repository
   * path if the layer has one, otherwise its resolved path. */
  @discardableResult
  static func open(_ filePath: String, ext: USDStage.FileExt, load: InitialLoadingSet = .all) -> UsdStage
  {
    Overlay.Dereference(
      "\(filePath).\(ext.rawValue)".withCString { Overlay.OpenStage($0, load.rawValue) }
    )
  }

  /**
   * Attempt to ensure a ``Usd.Prim`` at path is defined (according to ``Usd.Prim.isDefined()``) on this stage.
   *
   * If a prim at path is already defined on this stage and typeName is empty or equal to the existing prim's typeName,
   * return that prim. Otherwise, author an SdfPrimSpec with **specifier** == `Sdf.SpecifierDef` and typeName for
   * the prim at **path** at the current EditTarget. Lastly, author `Sdf.PrimSpec`s with the **specifier** set equal
   * to `Sdf.SpecifierDef` and an empty typeName at the current **edit target** for any nonexistent, or existing but
   * not Defined ancestors.
   *
   * The given path must be an absolute prim path that does not contain any variant selections. If it is impossible to author
   * any of the necessary `Sdf.PrimSpec`s (for example, in case path cannot map to the current UsdEditTarget's namespace
   * or one of the ancestors of path is inactive on the UsdStage), issue an error and return an invalid ``Usd.Prim``.
   *
   * > Note: This method may return a defined prim whose **type name** does not match the supplied **type name**,
   *   in case a stronger **type name** opinion overrides the opinion at the current **edit target**. */
  @discardableResult
  func definePrim(_ path: Sdf.Path, type name: Tf.Token = Tf.Token()) -> Usd.Prim
  {
    DefinePrim(path, name)
  }

  /**
   * Attempt to ensure a ``Usd.Prim`` at path is defined (according to ``Usd.Prim.isDefined()``) on this stage.
   *
   * If a prim at path is already defined on this stage and typeName is empty or equal to the existing prim's typeName,
   * return that prim. Otherwise, author an SdfPrimSpec with **specifier** == `Sdf.SpecifierDef` and typeName for
   * the prim at **path** at the current EditTarget. Lastly, author `Sdf.PrimSpec`s with the **specifier** set equal
   * to `Sdf.SpecifierDef` and an empty typeName at the current **edit target** for any nonexistent, or existing but
   * not Defined ancestors.
   *
   * The given path must be an absolute prim path that does not contain any variant selections. If it is impossible to author
   * any of the necessary `Sdf.PrimSpec`s (for example, in case path cannot map to the current UsdEditTarget's namespace
   * or one of the ancestors of path is inactive on the UsdStage), issue an error and return an invalid ``Usd.Prim``.
   *
   * > Note: This method may return a defined prim whose **type name** does not match the supplied **type name**,
   *   in case a stronger **type name** opinion overrides the opinion at the current **edit target**. */
  @discardableResult
  func definePrim(_ path: String, type name: Tf.Token = Tf.Token()) -> Usd.Prim
  {
    DefinePrim(.init(path), name)
  }

  /**
   * Return the ``Usd.Prim`` at `path`, or an invalid ``Usd.Prim`` if none exists.
   *
   * If path indicates a prim beneath an instance, returns an instance
   * proxy prim if a prim exists at the corresponding path in that instance's
   * prototype.
   *
   * Unlike ``UsdStage.overridePrim()`` and ``UsdStage.definePrim()``, this
   * method will never author scene description, and therefore is safe to
   * use as a "reader" in the Usd multi-threading model. */
  func getPrim(at path: Sdf.Path) -> Usd.Prim
  {
    GetPrimAtPath(path)
  }

  /**
   * Return the ``Usd.Prim`` at `path`, or an invalid ``Usd.Prim`` if none exists.
   *
   * If path indicates a prim beneath an instance, returns an instance
   * proxy prim if a prim exists at the corresponding path in that instance's
   * prototype.
   *
   * Unlike ``UsdStage.overridePrim()`` and ``UsdStage.definePrim()``, this
   * method will never author scene description, and therefore is safe to
   * use as a "reader" in the Usd multi-threading model. */
  func getPrim(at path: String) -> Usd.Prim
  {
    GetPrimAtPath(Sdf.Path(path))
  }

  /**
   * Attempt to ensure a ``Usd.Prim`` at path exists on this stage.
   *
   * If a prim already exists at path, return it. Otherwise author
   * ``SdfPrimSpecs`` with `specifier == SdfSpecifierOver` and empty
   * `typeName` at the current ``EditTarget`` to create this prim and any
   * nonexistent ancestors, then return it.
   *
   * The given path must be an absolute prim path that does not contain
   * any variant selections.
   *
   * If it is impossible to author any of the necessary PrimSpecs, (for
   * example, in case `path` cannot map to the current UsdEditTarget's
   * namespace) issue an error and return an invalid ``Usd.Prim``.
   *
   * If an ancestor of `path` identifies an inactive prim, author scene
   * description as described above but return an invalid prim, since the
   * resulting prim is descendant to an inactive prim. */
  func overridePrim(path: Sdf.Path) -> Usd.Prim
  {
    OverridePrim(path)
  }

  /**
   * Attempt to ensure a ``Usd.Prim`` at path exists on this stage.
   *
   * If a prim already exists at path, return it. Otherwise author
   * ``SdfPrimSpecs`` with `specifier == SdfSpecifierOver` and empty
   * `typeName` at the current ``EditTarget`` to create this prim and any
   * nonexistent ancestors, then return it.
   *
   * The given path must be an absolute prim path that does not contain
   * any variant selections.
   *
   * If it is impossible to author any of the necessary PrimSpecs, (for
   * example, in case `path` cannot map to the current UsdEditTarget's
   * namespace) issue an error and return an invalid ``Usd.Prim``.
   *
   * If an ancestor of `path` identifies an inactive prim, author scene
   * description as described above but return an invalid prim, since the
   * resulting prim is descendant to an inactive prim. */
  func overridePrim(path: String) -> Usd.Prim
  {
    OverridePrim(Sdf.Path(path))
  }

  /**
   * Set the default prim layer metadata in this stage's root layer.
   *
   * This is shorthand for:
   * ```swift
   * stage.getRootLayer().setDefaultPrim(prim.getName())
   * ```
   *
   * If prim is a root prim, otherwise
   * ```swift
   * stage.getRootLayer().setDefaultPrim(prim.getPath().getAsToken())
   * ```
   *
   * Note that this function always authors to the stage's root layer.
   * To author to a different layer, use the `SdfLayer.setDefaultPrim()` API. */
  func setDefaultPrim(_ prim: Usd.Prim)
  {
    SetDefaultPrim(prim)
  }

  /**
   * Return this stage's root layer. */
  func getRootLayer() -> SdfLayerHandle
  {
    GetRootLayer()
  }

  /**
   * Return this stage's root layer. */
  func getPseudoRoot() -> Usd.Prim
  {
    GetPseudoRoot()
  }

  /**
   * Traverse the active, loaded, defined, non-abstract prims on this stage depth-first.
   *
   * Returns a ``Usd.PrimRange`` , which allows low-latency traversal, with the
   * ability to prune subtrees from traversal. It is python iterable, so in its simplest form,
   * one can do:
   * ```swift
   * for prim in stage.traverse()
   * {
   *   print(prim.GetPath())
   * }
   * ```
   *
   * If either a pre-and-post-order traversal or, a traversal rooted at
   * a particular prim is desired, construct a ``Usd.PrimRange``
   * directly.
   *
   * This is equivalent to ``Usd.PrimRange.stage()``. */
  func traverse() -> [Usd.Prim]
  {
    let it = Usd.PrimRange.Stage(Overlay.TfWeakPtr(self), .init())

    return IteratorSequence(it).map { $0 }
  }

  /**
   * Calls Sdf/Layer/reload() on all layers contributing to this stage,
   * except session layers and sublayers of session layers.
   *
   * This includes non-session sublayers, references and payloads.
   * Note that reloading anonymous layers clears their content, so
   * invoking Reload() on a stage constructed via CreateInMemory()
   * will clear its root layer.
   *
   * \note This method is considered a mutation, which has potentially
   * global effect!  Unlike the various Load() methods whose actions
   * affect only **this stage**, Reload() may cause layers to change their
   * contents, and because layers are global resources shared by
   * potentially many Stages, calling Reload() on one stage may result in
   * a mutation to any number of stages.  In general, unless you are
   * highly confident your stage is the only consumer of its layers, you
   * should only call Reload() when you are assured no other threads may
   * be reading from any Stages. */
  func reload()
  {
    Reload()
  }

  /**
   * Modify this stage's load rules to load the prim at `path`, its
   * ancestors, and all of its descendants if `policy` is `.withDescendants`.
   *
   * If `policy` is `.withoutDescendants`, then payloads on descendant prims are not loaded. */
  @discardableResult
  func load(path: Sdf.Path = Sdf.Path.absoluteRootPath(), 
            policy: Pixar.UsdLoadPolicy = .withDescendants) -> Usd.Prim
  {
    Load(path, policy)
  }

  /**
   * Save all dirty layers contributing to this stage.
   *
   * Calls ``Sdf.Layer.save()`` on all dirty layers contributing to this stage
   * except session layers and sublayers of session layers. This function will emit a
   * warning and skip each dirty anonymous layer it encounters, since anonymous layers
   * cannot be saved with ``Sdf.Layer.save()``. These layers must be manually
   * exported by calling ``Sdf.Layer.export()``. */
  func save()
  {
    Save()
  }

  @discardableResult
  func getMetadata(_ key: String, _ value: inout Double) -> Bool
  {
    GetMetadata(Tf.Token(key), &value)
  }

  @discardableResult
  func getMetadata(_ key: String, _ value: inout Int) -> Bool
  {
    GetMetadata(Tf.Token(key), &value)
  }

  @discardableResult
  func getMetadata(_ key: String, _ value: inout Float) -> Bool
  {
    GetMetadata(Tf.Token(key), &value)
  }

  @discardableResult
  func getMetadata(_ key: String, _ value: inout Tf.Token) -> Bool
  {
    GetMetadata(Tf.Token(key), &value)
  }

  func hasAuthoredMetadata(_ key: String) -> Bool
  {
    HasAuthoredMetadata(Tf.Token(key))
  }

  @discardableResult
  func setMetadata(_ key: String, _ value: Double) -> Bool
  {
    Overlay.StageSetMetadata(self, Tf.Token(key), value)
  }

  @discardableResult
  func setMetadata(_ key: String, _ value: Int32) -> Bool
  {
    Overlay.StageSetMetadata(self, Tf.Token(key), value)
  }

  @discardableResult
  func setMetadata(_ key: String, _ value: Float) -> Bool
  {
    Overlay.StageSetMetadata(self, Tf.Token(key), value)
  }

  @discardableResult
  func setMetadata(_ key: String, _ value: Tf.Token) -> Bool
  {
    Overlay.StageSetMetadata(self, Tf.Token(key), value)
  }

  func exportToString(_ result: inout String, addSourceFileComment: Bool = true)
  {
    result = String(cString: Overlay.ExportStageToString(self, addSourceFileComment))
  }
  
  func getStartTimeCode() -> Double
  {
    GetStartTimeCode()
  }
}

#if !canImport(Usd)
extension Pixar.UsdLoadPolicy
{
  public static let withDescendants = Pixar.UsdLoadPolicy(rawValue: 0)
  public static let withoutDescendants = Pixar.UsdLoadPolicy(rawValue: 1)
}

extension Overlay
{
  public static func CreateNewStage(_ identifier: UnsafePointer<CChar>, _ load: Pixar.UsdStage.InitialLoadSet) -> Pixar.UsdStageRefPtr
  {
    Pixar.UsdStage.CreateNew(std.string(identifier), load)
  }
  
  public static func CreateInMemoryStage(_ identifier: UnsafePointer<CChar>, _ load: Pixar.UsdStage.InitialLoadSet) -> Pixar.UsdStageRefPtr
  {
    Pixar.UsdStage.CreateInMemory(std.string(identifier), load)
  }
  
  public static func OpenStage(_ filepath: UnsafePointer<CChar>, _ load: Pixar.UsdStage.InitialLoadSet) -> Pixar.UsdStageRefPtr
  {
    Pixar.UsdStage.Open(std.string(filepath), load)
  }
  
  public static func StageSetMetadata(_ stage: Pixar.UsdStage, _ key: Pixar.TfToken, _ value: Double) -> Bool
  {
    stage.SetMetadata(key, Pixar.VtValue(value))
  }
  
  public static func StageSetMetadata(_ stage: Pixar.UsdStage, _ key: Pixar.TfToken, _ value: Int32) -> Bool
  {
    stage.SetMetadata(key, Pixar.VtValue(value))
  }
  
  public static func StageSetMetadata(_ stage: Pixar.UsdStage, _ key: Pixar.TfToken, _ value: Float) -> Bool
  {
    stage.SetMetadata(key, Pixar.VtValue(value))
  }
  
  public static func StageSetMetadata(_ stage: Pixar.UsdStage, _ key: Pixar.TfToken, _ value: Tf.Token) -> Bool
  {
    stage.SetMetadata(key, Pixar.VtValue(value))
  }
  
  public static func ExportStageToString(_ stage: Pixar.UsdStage, _ addSourceFileComment: Bool) -> UnsafePointer<CChar>
  {
    var buf = std.string()
    stage.ExportToString(&buf, addSourceFileComment)
    return String(buf).withCString { $0 }
  }
}
#endif
