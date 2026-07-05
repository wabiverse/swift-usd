/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#if canImport(Sdf)
  import Sdf
#else
  import OpenUSD
#endif

public typealias SdfVariability = Pixar.SdfVariability

public extension Sdf
{
  typealias Variability = SdfVariability
}

extension Sdf.Variability
{
  public static let varying = Pixar.SdfVariabilityVarying
  public static let uniform = Pixar.SdfVariabilityUniform
}
