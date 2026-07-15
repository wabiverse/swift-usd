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

extension UsdView
{
  /**
   * Create a basic usd scene. */
  static func createScene() -> UsdStage
  {
    /* Create stage with a dome light & sphere on a transform. */

    let stage = Usd.Stage.createNew("\(documentsDirPath())/HelloWorldExample", ext: .usd)

    let domeLight = UsdLux.DomeLight.define(stage, path: "/World/DefaultDomeLight")

    if let hdxResources = Bundle.hdx?.resourcePath {
      let tex = "\(hdxResources)/textures/StinsonBeach.hdr"

      if FileManager.default.fileExists(atPath: tex) {
        let hdrAsset = Sdf.AssetPath(tex)
        domeLight.createTextureFileAttr().set(hdrAsset)
      }
    }

    let xform = UsdGeom.Xform.define(stage, path: "/Geometry")
    xform.addXformOp(type: .translate).set(GfVec3d(0.0, 0.0, 0.0))
    xform.addXformOp(type: .scale, precision: .float).set(GfVec3f(1, 1, 1))

    let sphere = UsdGeom.Sphere.define(stage, path: "/Geometry/Sphere")

    /* Create a colored material for the sphere prim. */

    UsdShade.MaterialBindingAPI.apply(sphere).bind(matDef(stage, color: .red))

    /* Iterate the stage and print out the path to each prim. */

    for prim in stage.traverse()
    {
      let primType = !prim.typeName.isEmpty ? "(\(prim.typeName.string))" : ""
      Msg.logger.log(level: .info, "\(prim.name.string)\(primType) -> \(prim.path.string)")
    }

    /* Save the stage to disk. */

    stage.getPseudoRoot().set(doc: "SwiftUSD v\(Pixar.version)")
    stage.save()

    return stage
  }
  
  /**
   * Open a usd scene if the executable was passed
   * '--usd /path/to/usd/stage.usda' , otherwise create
   * a new basic usd scene. */
  static func createOrOpenScene() -> UsdStage
  {
    let stage: UsdStage
    if let scenePath = scenePathFromArgs() {
      stage = Usd.Stage.open(scenePath)
    } else {
      stage = Self.createScene()
    }
    
    return stage
  }
}
