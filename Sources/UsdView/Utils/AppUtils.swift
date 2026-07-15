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
import OpenUSDKit
import SwiftCrossUI

/// `true` on platforms where vertical space is at a premium and panels
/// should stack instead of sitting side-by-side (iOS, Android).
public let isCompactLayout: Bool = {
  #if os(iOS) || os(Android)
    true
  #else
    false
  #endif
}()

public extension View
{
  /// Sizes a sidebar pane: a fixed height on compact layouts (where panes
  /// stack vertically), or a fixed width otherwise (where panes sit
  /// side-by-side).
  @ViewBuilder
  func sidebarFrame() -> some View
  {
    if isCompactLayout
    {
      frame(height: 200)
    }
    else
    {
      frame(width: 320)
    }
  }

  /// Gives a split pane a sensible minimum size: enough height to be usable
  /// when stacked vertically on compact layouts, or enough width when laid
  /// out side-by-side.
  @ViewBuilder
  func splitPaneMinSize() -> some View
  {
    if isCompactLayout
    {
      frame(minHeight: 400)
    }
    else
    {
      frame(minWidth: 520)
    }
  }
}

/// path to a user's documents directory.
public func documentsDirPath() -> String
{
  #if os(macOS) || os(iOS) || os(visionOS) || os(tvOS) || os(watchOS)
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].path
  #elseif os(Android)
    // On Android, the working directory is `/` (no write permission).
    // Use the app's private files directory, which is already set by
    // UsdView.init() before createOrOpenScene() is called.
    let filesDir = Pixar.Bundler.androidFilesDir
    return filesDir.isEmpty ? "/data/local/tmp" : filesDir
  #else
    return "."
  #endif
}

/// returns the stage path if the executable was passed
/// '--usd /path/to/usd/stage.usda' , otherwise `nil`.
public func scenePathFromArgs() -> String?
{
  let arguments = CommandLine.arguments
  if let index = arguments.firstIndex(of: "--usd"), index + 1 < arguments.count
  {
    return arguments[index + 1]
  }
  if let path = ProcessInfo.processInfo.environment["LATTICE_USD_SCENE"], !path.isEmpty
  {
    return path
  }
  return nil
}
