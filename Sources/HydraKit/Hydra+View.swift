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
import OpenUSDKit
import SwiftCrossUI

#if canImport(Metal)
  import Metal
  import MetalKit
#endif // canImport(Metal)

public extension Hydra
{
  #if os(macOS) || os(iOS) || os(visionOS)
    typealias Viewport = Hydra.MTLView
  #elseif os(tvOS) || os(watchOS)
    typealias Viewport = UIViewRepresentable
  #else // os(Linux) || os(Windows)
    struct Viewport: View
    {
      public var body: some View {
        Text("Hello World.")
      }
    }
  #endif // os(macOS) || os(iOS) || os(visionOS)
}

public extension Hydra.Viewport
{
  init(engine: Hydra.RenderEngine)
  {
    #if canImport(Metal)
      let renderer = Hydra.MTLRenderer(hydra: engine)
      self.init(hydra: engine, renderer: renderer)
    #endif // canImport(Metal)
  }
}
