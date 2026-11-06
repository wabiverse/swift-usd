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

#if canImport(Tf)
  import Tf
  import Plug
#else
  import OpenUSD
#endif

/* note: the typealiases are documented the same way twice,
 * keep it like this so that sourcekit shows documentation
 * regardless of which typealias a user might use in their
 * code. */

/**
 * # TfToken
 *
 * ## Overview
 *
 * **Token** for efficient comparison, assignment, and hashing of known strings.
 *
 * A TfToken is a handle for a registered string, and can be compared,
 * assigned, and hashed in constant time. It is useful when a bounded
 * number of strings are used as fixed symbols (but never modified). */
public typealias TfToken = Pixar.TfToken

public extension Tf
{
  /**
   * # Tf.Token
   *
   * ## Overview
   *
   * **Token** for efficient comparison, assignment, and hashing of known strings.
   *
   * A TfToken is a handle for a registered string, and can be compared,
   * assigned, and hashed in constant time. It is useful when a bounded
   * number of strings are used as fixed symbols (but never modified). */
  typealias Token = TfToken
}

#if canImport(Tf)
extension TfToken: Equatable
{
  public static func == (lhs: TfToken, rhs: TfToken) -> Bool
  {
    lhs.Hash() == rhs.Hash()
  }
}

extension TfToken: Hashable
{
  public func hash(into hasher: inout Hasher)
  {
    hasher.combine(Hash())
  }
}
#endif

public extension TfToken
{
  init(_ value: String)
  {
    self = value.withCString { Overlay.MakeToken($0) }
  }

  var string: String
  {
    String(cString: Overlay.GetTokenText(self))
  }

  var isEmpty: Bool
  {
    IsEmpty()
  }
}

#if !canImport(Tf)
extension Overlay
{
  public static func MakeToken(_ value: UnsafePointer<CChar>) -> Tf.Token
  {
    Tf.Token(value)
  }
  
  public static func GetTokenText(_ value: Tf.Token) -> UnsafePointer<CChar>
  {
    String(value.GetString()).withCString { $0 }
  }
}
#endif

/// Tokens are immutable handles into a thread safe registry, so they're free to cross threads.
extension TfToken: @unchecked Sendable {}
