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
import CxxStdlib

#if canImport(pxr)
  @_exported import pxr
#else
  @_exported import OpenUSD
  
  public typealias Pixar = pxr

  let SWIFTUSD_EVOLUTION: Int32 = 2
#endif

/* --- xxx --- */

public extension Pixar
{
  /**
   * The current version of ``OpenUSDKit``.
   *
   * The semantic versioning used for ``OpenUSDKit`` tracks both the upstream
   * OpenUSD version, as well as the evolution iteration of the ``swift-usd``
   * SwiftPM package, which is setup as follows:
   * - ``PXR_MINOR_VERSION``.``PXR_PATCH_VERSION``.``SWIFTUSD_EVOLUTION`` */
  static let version = String(format: "%d.%02d.%d",
    PXR_MINOR_VERSION,
    PXR_PATCH_VERSION,
    SWIFTUSD_EVOLUTION
  )
}

/* --- xxx --- */
