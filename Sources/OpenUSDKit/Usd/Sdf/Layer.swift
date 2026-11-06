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
#if canImport(Sdf)
  import Sdf
#else
  import OpenUSD
#endif

public typealias SdfLayer = Pixar.SdfLayer
public typealias SdfLayerHandle = Pixar.SdfLayerHandle

public extension Sdf
{
  typealias Layer = SdfLayer
  typealias LayerHandle = SdfLayerHandle
}

public extension SdfLayerHandle
{
  /**
   * Sets the documentation string for this layer. */
  func set(doc: String)
  {
    doc.withCString { Overlay.SetDocumentation(self, $0) }
  }

  /**
   * Returns `true` if successful, `false` if an error occurred.
   * Returns `false` if the layer has no remembered file name or the
   * layer type cannot be saved. The layer will not be overwritten if the
   * file exists and the layer is not dirty unless `force` is true. */
  func save(force: Bool = false)
  {
    #if canImport(Sdf)
      pointee.Save(force)
    #else
      Overlay.Dereference(self).Save(force)
    #endif
  }

  /**
   * Reloads the layer from its persistent representation.
   *
   * This restores the layer to a state as if it had just been created
   * with ``SdfLayer/findOrOpen()``. This operation is undoable.
   *
   * The fileName and whether journaling is enabled are not affected
   * by this method.
   *
   * When called with force = false (the default), Reload attempts to
   * avoid reloading layers that have not changed on disk. It does so
   * by comparing the file's modification time (mtime) to when the
   * file was loaded. If the layer has unsaved modifications, this
   * mechanism is not used, and the layer is reloaded from disk. If the
   * layer has any ``SdfLayer/getExternalAssetDependencies()`` "external
   * asset dependencies", their modification state will also be consulted
   * when determining if the layer needs to be reloaded.
   *
   * Passing true to the `force` parameter overrides this behavior, forcing
   * the layer to be reloaded from disk regardless of whether it has changed. */
  func reload(force: Bool = false)
  {
    #if canImport(Sdf)
      pointee.Reload(force)
    #else
      Overlay.Dereference(self).Reload(force)
    #endif
  }
}


#if !canImport(Sdf)
extension Overlay
{
  public static func SetDocumentation(_ layer: SdfLayerHandle, _ doc: UnsafePointer<CChar>)
  {
    Overlay.Dereference(layer).SetDocumentation(std.string(doc))
  }
}
#endif

public extension SdfLayerHandle
{
  /// The layer's identifier, what ``SdfLayer`` finds and opens it by.
  var identifier: String
  {
    #if canImport(Sdf)
      String(pointee.__GetIdentifierUnsafe().pointee)
    #else
      String(Overlay.Dereference(self).GetIdentifier())
    #endif
  }

  /// The resolved path of the file the layer reads from and saves to, empty for an anonymous layer.
  var realPath: String
  {
    #if canImport(Sdf)
      String(pointee.__GetRealPathUnsafe().pointee)
    #else
      String(Overlay.Dereference(self).GetRealPath())
    #endif
  }
}
