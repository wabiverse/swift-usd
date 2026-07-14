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

public extension Hydra
{
  /**
   * ``NORenderer``
   *
   * ## Overview
   *
   * The Hydra Engine (``Hd``) no-op renderer for the ``UsdView``
   * application. Note: This renders nothing. */
  class NORenderer
  {
    public var stage: UsdStage

    public required init(stage: UsdStage)
    {
      self.stage = stage
    }

    public func info()
    {
      Msg.logger.log(level: .info, "Created HGI -> None.")
    }
  }
}
