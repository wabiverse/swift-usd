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

#if canImport(Hdx)
  import Hdx
#else
  import OpenUSD
#endif

private extension Hdx
{
  /**
   * Private struct to hold the static
   * data for the Hdx library. */
  struct StaticData: @unchecked Sendable
  {
    static let shared = StaticData()
    private init()
    {}

    let tokens = Pixar.HdxColorCorrectionTokens_StaticTokenType()
  }
}

public extension Hdx
{
  /**
   * # Hdx.Tokens
   *
   * ## Overview
   *
   * Public, client facing api to access
   * the static Hdx tokens. */
  enum ColorCorrectionTokens: String, CaseIterable
  {
    case disabled
    case sRGB
    case openColorIO

    public var token: Tf.Token
    {
      switch self
      {
        case .disabled: StaticData.shared.tokens.disabled
        case .sRGB: StaticData.shared.tokens.sRGB
        case .openColorIO: StaticData.shared.tokens.openColorIO
      }
    }
  }
}

public extension Tf.Token
{
  nonisolated(unsafe) static let disabled = Hdx.ColorCorrectionTokens.disabled.token
  nonisolated(unsafe) static let sRGB = Hdx.ColorCorrectionTokens.sRGB.token
  nonisolated(unsafe) static let openColorIO = Hdx.ColorCorrectionTokens.openColorIO.token
}
