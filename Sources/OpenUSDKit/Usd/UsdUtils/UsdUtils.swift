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

#if canImport(UsdUtils)
  import UsdUtils
#else
  import OpenUSD
#endif

public enum UsdUtils
{}

public extension Tf.Token
{
  /// The primvar USD's tools read a mesh's main uv set from, `st`.
  nonisolated(unsafe) static let primaryUVSet = Pixar.UsdUtilsGetPrimaryUVSetName().pointee
}
