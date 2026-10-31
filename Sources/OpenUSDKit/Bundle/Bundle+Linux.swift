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

#if canImport(Arch)
  import Arch
#else
  import OpenUSD
#endif
import CxxStdlib
import Foundation
#if !os(Android)
  import Rainbow
#endif

#if os(Linux)
  /**
   * On Linux there is no ``Foundation.Bundle``, so we create one.
   */
//  public final class Bundle: Sendable
//  {
//    public static let main = Bundle()
//
//    public let resourcePath: String?
//
//    private init()
//    {
//      resourcePath = "/" + Arch.getExecutablePath().split(separator: "/").dropLast().joined(separator: "/")
//      Msg.logger.log(level: .info, "Bundle path: \(resourcePath ?? "")")
//    }
//
//    public init?(path: String)
//    {
//      guard FileManager.default.fileExists(atPath: path, isDirectory: nil) else { return nil }
//      resourcePath = path
//    }
//  }
#endif /* os(Linux) */
