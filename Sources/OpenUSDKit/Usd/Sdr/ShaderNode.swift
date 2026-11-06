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

#if canImport(Sdr)
  import Sdr
#else
  import OpenUSD
#endif

public typealias SdrShaderNode = Pixar.SdrShaderNode

public extension Sdr
{
  typealias ShaderNode = SdrShaderNode
}

public extension SdrShaderNode
{
  /// The names of the node's inputs, in the order its definition gives them.
  var shaderInputNames: [Tf.Token]
  {
    #if canImport(Sdr)
      Array(__GetShaderInputNamesUnsafe().pointee)
    #else
      Array(GetShaderInputNames())
    #endif
  }
}
