/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
import OpenUSDKit
import HydraKit
import SwiftCrossUI

/**
 * ``UsdView``
 *
 * ## Overview
 *
 * A "run everywhere" USD viewer, written entirely in Swift.
 *
 * ``UsdView`` pairs **Hydra** - Pixar's USD imaging engine - with
 * **SwiftCrossUI** to bring one SwiftUI-style codebase to every platform
 * Swift reaches: macOS, iOS, visionOS, Linux, Windows, and Android. Browsing,
 * inspecting, and orbiting USD stages with platform native UI everywhere. */
@main
struct UsdView: App
{
  typealias Backend = PlatformBackend

  /// the active usd stage.
  let stage: UsdStage
  /// the hydra rendering engine.
  let engine: Hydra.RenderEngine

  public init()
  {
    // register all usd plugins & resources.
    Pixar.Bundler.shared.setup(.resources)

    // create a new usd stage.
    stage = UsdView.createScene()

    // setup hydra to render the usd stage.
    engine = Hydra.RenderEngine(stage: stage)

    Msg.logger.log(level: .info, "UsdView launched | USD v\(Pixar.version).")
  }

  @State private var selectedPath: String? = nil

  var body: some Scene
  {
    WindowGroup("UsdView") {
      SplitPane(spacing: 0) {
        PrimBrowserView(stage: stage, selectedPath: $selectedPath)
          .sidebarFrame()

        Hydra.Viewport(engine: engine)
      }
      .splitPaneMinSize()
      .colorScheme(.dark)
    }
  }
}
