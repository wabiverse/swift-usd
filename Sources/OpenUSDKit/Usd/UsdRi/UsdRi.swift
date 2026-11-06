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

#if canImport(UsdRi)
  import UsdRi
#else
  import OpenUSD
#endif

public enum UsdRi
{}

public extension Tf.Token
{
  /// "ri", RenderMan's render context, for material terminals like `outputs:ri:surface`.
  nonisolated(unsafe) static let riRenderContext = Pixar.UsdRiTokensType().renderContext
}
