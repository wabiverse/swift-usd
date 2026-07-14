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

#if canImport(HgiGL)
import HgiGL

public extension Hydra
{
  /**
   * ``GLRenderer``
   *
   * ## Overview
   *
   * The Hydra Engine (``Hd``) OpenGL renderer for the ``UsdView``
   * application. */
  class GLRenderer
  {
    let hgi: Pixar.HgiGL
    var device: Pixar.HgiGLDevice!

    public var stage: UsdStage

    var engine: UsdImagingGL.Engine

    public required init(stage: UsdStage)
    {
      hgi = HgiGL.createHgi()
      device = hgi.device
      self.stage = stage

      let driver = HdDriver(name: .renderDriver, driver: hgi.value)

      engine = UsdImagingGL.Engine.createEngine(
        rootPath: stage.getPseudoRoot().getPath(),
        excludedPaths: Sdf.PathVector(),
        invisedPaths: Sdf.PathVector(),
        sceneDelegateId: Sdf.Path.absoluteRootPath(),
        driver: driver
      )

      engine.setEnablePresentation(false)
      engine.setRendererAov(.color)
    }

    public func info()
    {
      Msg.logger.log(level: .info, "Created HGI -> OpenGL.")
    }
  }
}
#endif
