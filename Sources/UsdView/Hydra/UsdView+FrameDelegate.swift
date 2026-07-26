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

import OpenUSDKit
import HydraKit

extension UsdView
{
  public final class FrameDelegate: Hydra.FrameDelegate
  {
    /// the active usd stage.
    public let stage: UsdStage

    /// weak: the app owns the hydra render engine.
    public weak var engine: Hydra.RenderEngine?
    
    public init(stage: UsdStage, hydra: Hydra.RenderEngine)
    {
      self.stage = stage
      self.engine = hydra
      
      self.engine?.frameDelegate = self
    }
    
    /// Called before Hydra pulls the scene index chain for this frame.
    public func hydraWillPull(deltaTime: Double)
    {
      guard let engine else { return }

      // static (non-animated) stages have no authored
      // range at all, leave currentTimeCode untouched
      // rather than looping nothing.
      guard stage.HasAuthoredTimeCodeRange() else { return }

      let start = stage.getStartTimeCode()
      let end = stage.GetEndTimeCode()
      let range = end - start
      guard range > 0 else { return }

      let timeCodesPerSecond = stage.GetTimeCodesPerSecond()
      let clamped = min(max(deltaTime, 1.0 / 240.0), 1.0 / 20.0)
      var next = engine.currentTimeCode + clamped * timeCodesPerSecond

      // loop animation playback.
      if next > end
      {
        next = start + (next - start).truncatingRemainder(dividingBy: range)
      }

      engine.currentTimeCode = next
    }

    /// Called once Hydra has finished pulling.
    public func hydraDidPull()
    {}
  }
}
