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

public extension Hydra
{
  /// Notified around each frame's scene-index pull, so an application can advance
  /// whatever drives the scene before Hydra reads it.
  ///
  /// `willPull` is the mutation window: everything the frame's scene indices will
  /// be asked for should be settled and dirtied by the time it returns. `didPull`
  /// closes the window. Hydra reads concurrently between the two.
  protocol FrameDelegate: AnyObject
  {
    /// Called before Hydra pulls the scene index chain for this frame.
    func hydraWillPull(deltaTime: Double)

    /// Called once Hydra has finished pulling. Always paired with `hydraWillPull`,
    /// including on error paths.
    func hydraDidPull()
  }
}
