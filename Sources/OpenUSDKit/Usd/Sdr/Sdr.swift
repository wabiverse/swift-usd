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

/**
 * # ``Sdr``
 *
 * **Shader Definition Registry**
 *
 * ## Overview
 *
 * **Sdr** is a shading-specialized version of Ndr, and provides the following
 * specialized classes:
 * - ``Sdr/Registry``: A registry for nodes that describe shading information.
 * - ``Sdr/ShaderNode``: A node that describes a shader.
 * - ``Sdr/ShaderProperty``: A node that describes a shader property.
 *
 * For more details on the registry, nodes, or properties, see the base Ndr
 * classes:
 * - ``Ndr/Registry``: A registry for nodes that describe information.
 * - ``Ndr/Node``: Represents an abstract node.
 * - ``Ndr/Property``: Represents a property (input or output) that is part of a ``Ndr/Node``. */
public enum Sdr
{}

public extension Tf.Token
{
  /// The `widget` hint a shader property is shown with as a checkbox.
  static let checkBox = Tf.Token("checkBox")
}
