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

import Foundation

public extension Bundle
{
  /**
   * Resolves plugin resource paths for both bundled and unbundled app contexts,
   * handling both '.bundle' and '.resources' extensions, and the Contents/Resources
   * nesting inside app bundles. */
  static func hydraKitBundle(_ name: String) -> Bundle?
  {
    let pxrRoot = Bundle.main.resourcePath ?? ""
    let base = ["\(pxrRoot)/\(name).bundle", "\(pxrRoot)/\(name).resources"]
      .first { FileManager.default.fileExists(atPath: $0) }
    guard let base else { return nil }

    return Bundle(path: "\(base)/Contents/Resources") ?? Bundle(path: base)
  }
  
  static let hydraKit: Bundle = {
    // in bundled app contexts, swift bundler nests compiled resources under
    // Contents/Resources - check there before falling back to .module.
    if let bundle = hydraKitBundle("swift-usd_HydraKit")
    { return bundle }
    return .module
  }()
}
