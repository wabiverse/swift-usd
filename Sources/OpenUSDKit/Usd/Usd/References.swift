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

public typealias UsdReferences = Pixar.UsdReferences

public extension Usd
{
  typealias References = UsdReferences
}

public extension Usd.References
{
  @discardableResult
  mutating func addReference(_ ref: Sdf.Reference, position: Pixar.UsdListPosition = .backOfPrependList) -> Bool
  {
    AddReference(ref, position)
  }

  @discardableResult
  mutating func addReference(assetPath: String,
                             primPath: Sdf.Path,
                             layerOffset: Sdf.LayerOffset = Sdf.LayerOffset(0, 1),
                             position: Pixar.UsdListPosition = .backOfPrependList) -> Bool
  {
    assetPath.withCString { Overlay.AddReference(self, $0, primPath, layerOffset, position) }
  }

  @discardableResult
  mutating func addReference(assetPath: String,
                             layerOffset: Sdf.LayerOffset = Sdf.LayerOffset(0, 1),
                             position: Pixar.UsdListPosition = .backOfPrependList) -> Bool
  {
    assetPath.withCString { Overlay.AddReference(self, $0, layerOffset, position) }
  }
}

#if !canImport(Usd)
extension Pixar.UsdListPosition
{
  /// The position at the front of the prepend list.
  /// An item added at this position will, after composition is applied,
  /// be stronger than other items prepended in this layer, and stronger
  /// than items added by weaker layers.
  public static let frontOfPrependList = Pixar.UsdListPosition(rawValue: 0)
  /// The position at the back of the prepend list.
  /// An item added at this position will, after composition is applied,
  /// be weaker than other items prepended in this layer, but stronger
  /// than items added by weaker layers.
  public static let backOfPrependList = Pixar.UsdListPosition(rawValue: 1)
  /// The position at the front of the append list.
  /// An item added at this position will, after composition is applied,
  /// be stronger than other items appended in this layer, and stronger
  /// than items added by weaker layers.
  public static let frontOfAppendList = Pixar.UsdListPosition(rawValue: 2)
  /// The position at the back of the append list.
  /// An item added at this position will, after composition is applied,
  /// be weaker than other items appended in this layer, but stronger
  /// than items added by weaker layers.
  public static let backOfAppendList = Pixar.UsdListPosition(rawValue: 3)
}

extension Overlay
{
  public static func AddReference(_ reference: Usd.References,
                                  _ assetPath: UnsafePointer<CChar>,
                                  _ primPath: Sdf.Path,
                                  _ layerOffset: Sdf.LayerOffset,
                                  _ position: Pixar.UsdListPosition) -> Bool
  {
    reference.AddReference(std.string(assetPath), primPath, layerOffset, position)
  }
  
  public static func AddReference(_ reference: Usd.References,
                                  _ assetPath: UnsafePointer<CChar>,
                                  _ layerOffset: Sdf.LayerOffset,
                                  _ position: Pixar.UsdListPosition) -> Bool
  {
    reference.AddReference(std.string(assetPath), layerOffset, position)
  }
}
#endif
