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

public extension Bundle
{
  /**
   * Resolves plugin resource paths for both bundled and unbundled app contexts,
   * handling both '.bundle' and '.resources' extensions, and the Contents/Resources
   * nesting inside app bundles. */
  static func pxrBundle(_ name: String) -> Bundle?
  {
    let pxrRoot = Bundle.main.resourcePath ?? ""
    let base = ["\(pxrRoot)/\(name).bundle", "\(pxrRoot)/\(name).resources"]
      .first { FileManager.default.fileExists(atPath: $0) }
    guard let base else { return nil }

    return Bundle(path: "\(base)/Contents/Resources") ?? Bundle(path: base)
  }

  /**
   * Where ``Ar`` application bundle resources are located. */
  static let ar = pxrBundle("swift-usd_Ar")

  /**
   * Where ``Sdf`` application bundle resources are located. */
  static let sdf = pxrBundle("swift-usd_Sdf")

  /**
   * Where ``Usd`` application bundle resources are located. */
  static let usd = pxrBundle("swift-usd_Usd")

  /**
   * Where ``Ndr`` application bundle resources are located. */
  static let ndr = pxrBundle("swift-usd_Ndr")

  /**
   * Where ``UsdGeom`` application bundle resources are located. */
  static let usdGeom = pxrBundle("swift-usd_UsdGeom")

  /**
   * Where ``UsdShade`` application bundle resources are located. */
  static let usdShade = pxrBundle("swift-usd_UsdShade")

  /**
   * Where ``UsdShaders`` application bundle resources are located. */
  static let usdShaders = pxrBundle("swift-usd_UsdShaders")

  /**
   * Where ``UsdLux`` application bundle resources are located. */
  static let usdLux = pxrBundle("swift-usd_UsdLux")

  /**
   * Where ``UsdLod`` application bundle resources are located. */
  static let usdLod = pxrBundle("swift-usd_UsdLod")
  
  /**
   * Where ``UsdHydra`` application bundle resources are located. */
  static let usdHydra = pxrBundle("swift-usd_UsdHydra")

  /**
   * Where ``SdrOsl`` application bundle resources are located. */
  static let sdrOsl = pxrBundle("swift-usd_SdrOsl")

  /**
   * Where ``UsdAbc`` application bundle resources are located. */
  static let usdAbc = pxrBundle("swift-usd_UsdAbc")

  /**
   * Where ``UsdDraco`` application bundle resources are located. */
  static let usdDraco = pxrBundle("swift-usd_UsdDraco")

  /**
   * Where ``UsdMedia`` application bundle resources are located. */
  static let usdMedia = pxrBundle("swift-usd_UsdMedia")

  /**
   * Where ``UsdMtlx`` application bundle resources are located. */
  static let usdMtlx = pxrBundle("swift-usd_UsdMtlx")

  /**
   * Where ``UsdPhysics`` application bundle resources are located. */
  static let usdPhysics = pxrBundle("swift-usd_UsdPhysics")

  /**
   * Where ``UsdProc`` application bundle resources are located. */
  static let usdProc = pxrBundle("swift-usd_UsdProc")

  /**
   * Where ``UsdRender`` application bundle resources are located. */
  static let usdRender = pxrBundle("swift-usd_UsdRender")

  /**
   * Where ``UsdRi`` application bundle resources are located. */
  static let usdRi = pxrBundle("swift-usd_UsdRi")

  /**
   * Where ``UsdSkel`` application bundle resources are located. */
  static let usdSkel = pxrBundle("swift-usd_UsdSkel")

  /**
   * Where ``UsdUI`` application bundle resources are located. */
  static let usdUI = pxrBundle("swift-usd_UsdUI")

  /**
   * Where ``UsdVol`` application bundle resources are located. */
  static let usdVol = pxrBundle("swift-usd_UsdVol")

  /**
   * Where ``Hd`` application bundle resources are located. */
  static let hd = pxrBundle("swift-usd_Hd")

  /**
   * Where ``HgiMetal`` application bundle resources are located. */
  static let hgiMetal = pxrBundle("swift-usd_HgiMetal")

  /**
   * Where ``HgiVulkan`` application bundle resources are located. */
  static let hgiVulkan = pxrBundle("swift-usd_HgiVulkan")

  /**
   * Where ``HgiGL`` application bundle resources are located. */
  static let hgiGL = pxrBundle("swift-usd_HgiGL")

  /**
   * Where ``HdSi`` application bundle resources are located. */
  static let hdSi = pxrBundle("swift-usd_HdSi")
  
  /**
   * Where ``HdSt`` application bundle resources are located. */
  static let hdSt = pxrBundle("swift-usd_HdSt")

  /**
   * Where ``HdStorm`` application bundle resources are located. */
  static let hdStorm = pxrBundle("swift-usd_HdStorm")

  /**
   * Where ``Hdx`` application bundle resources are located. */
  static let hdx = pxrBundle("swift-usd_Hdx")

  /**
   * Where ``Hio`` application bundle resources are located. */
  static let hio = pxrBundle("swift-usd_Hio")
  
  /**
   * Where ``HioAVIF`` application bundle resources are located. */
  static let hioAVIF = pxrBundle("swift-usd_HioAVIF")
  
  /**
   * Where ``HioImageIO`` application bundle resources are located. */
  static let hioImageIO = pxrBundle("swift-usd_HioImageIO")
  
  /**
   * Where ``HioOIIO`` application bundle resources are located. */
  static let hioOIIO = pxrBundle("swift-usd_HioOIIO")
  
  /**
   * Where ``HioOpenEXR`` application bundle resources are located. */
  static let hioOpenEXR = pxrBundle("swift-usd_HioOpenEXR")
  
  /**
   * Where ``HioOpenVDB`` application bundle resources are located. */
  static let hioOpenVDB = pxrBundle("swift-usd_HioOpenVDB")

  /**
   * Where ``Glf`` application bundle resources are located. */
  static let glf = pxrBundle("swift-usd_Glf")

  /**
   * Where ``UsdImaging`` application bundle resources are located. */
  static let usdImaging = pxrBundle("swift-usd_UsdImaging")

  /**
   * Where ``UsdImagingGL`` application bundle resources are located. */
  static let usdImagingGL = pxrBundle("swift-usd_UsdImagingGL")

  /**
   * Where ``Tf`` python bundle resources are located. */
  static let pyTf = pxrBundle("swift-usd_PyTf")

  /**
   * Where ``Plug`` python bundle resources are located. */
  static let pyPlug = pxrBundle("swift-usd_PyPlug")

  /**
   * Where ``Trace`` python bundle resources are located. */
  static let pyTrace = pxrBundle("swift-usd_PyTrace")

  /**
   * Where ``Work`` python bundle resources are located. */
  static let pyWork = pxrBundle("swift-usd_PyWork")

  /**
   * Where ``Gf`` python bundle resources are located. */
  static let pyGf = pxrBundle("swift-usd_PyGf")

  /**
   * Where ``Vt`` python bundle resources are located. */
  static let pyVt = pxrBundle("swift-usd_PyVt")

  /**
   * Where ``Ar`` python bundle resources are located. */
  static let pyAr = pxrBundle("swift-usd_PyAr")

  /**
   * Where ``Kind`` python bundle resources are located. */
  static let pyKind = pxrBundle("swift-usd_PyKind")

  /**
   * Where ``Sdf`` python bundle resources are located. */
  static let pySdf = pxrBundle("swift-usd_PySdf")

  /**
   * Where ``Pcp`` python bundle resources are located. */
  static let pyPcp = pxrBundle("swift-usd_PyPcp")

  /**
   * Where ``Usd`` python bundle resources are located. */
  static let pyUsd = pxrBundle("swift-usd_PyUsd")

  /**
   * Where ``Ndr`` python bundle resources are located. */
  static let pyNdr = pxrBundle("swift-usd_PyNdr")

  /**
   * Where ``Sdr`` python bundle resources are located. */
  static let pySdr = pxrBundle("swift-usd_PySdr")

  /**
   * Where ``SdrOsl`` application bundle resources are located. */
  static let pySdrOsl = pxrBundle("swift-usd_PySdrOsl")

  /**
   * Where ``UsdGeom`` python bundle resources are located. */
  static let pyUsdGeom = pxrBundle("swift-usd_PyUsdGeom")

  /**
   * Where ``UsdShade`` python bundle resources are located. */
  static let pyUsdShade = pxrBundle("swift-usd_PyUsdShade")

  /**
   * Where ``UsdShaders`` application bundle resources are located. */
  static let pyUsdShaders = pxrBundle("swift-usd_PyUsdShaders")

  /**
   * Where ``UsdLod`` application bundle resources are located. */
  static let pyUsdLod = pxrBundle("swift-usd_PyUsdLod")
  
  /**
   * Where ``UsdLux`` application bundle resources are located. */
  static let pyUsdLux = pxrBundle("swift-usd_PyUsdLux")

  /**
   * Where ``UsdAbc`` application bundle resources are located. */
  static let pyUsdAbc = pxrBundle("swift-usd_PyUsdAbc")

  /**
   * Where ``UsdDraco`` application bundle resources are located. */
  static let pyUsdDraco = pxrBundle("swift-usd_PyUsdDraco")

  /**
   * Where ``UsdMedia`` application bundle resources are located. */
  static let pyUsdMedia = pxrBundle("swift-usd_PyUsdMedia")

  /**
   * Where ``UsdMtlx`` application bundle resources are located. */
  static let pyUsdMtlx = pxrBundle("swift-usd_PyUsdMtlx")

  /**
   * Where ``UsdPhysics`` application bundle resources are located. */
  static let pyUsdPhysics = pxrBundle("swift-usd_PyUsdPhysics")

  /**
   * Where ``UsdProc`` application bundle resources are located. */
  static let pyUsdProc = pxrBundle("swift-usd_PyUsdProc")

  /**
   * Where ``UsdRender`` application bundle resources are located. */
  static let pyUsdRender = pxrBundle("swift-usd_PyUsdRender")

  /**
   * Where ``UsdRi`` application bundle resources are located. */
  static let pyUsdRi = pxrBundle("swift-usd_PyUsdRi")

  /**
   * Where ``UsdSkel`` application bundle resources are located. */
  static let pyUsdSkel = pxrBundle("swift-usd_PyUsdSkel")

  /**
   * Where ``UsdUI`` application bundle resources are located. */
  static let pyUsdUI = pxrBundle("swift-usd_PyUsdUI")

  /**
   * Where ``UsdUtils`` application bundle resources are located. */
  static let pyUsdUtils = pxrBundle("swift-usd_PyUsdUtils")

  /**
   * Where ``UsdVol`` application bundle resources are located. */
  static let pyUsdVol = pxrBundle("swift-usd_PyUsdVol")

  /**
   * Where ``UsdHydra`` application bundle resources are located. */
  static let pyUsdHydra = pxrBundle("swift-usd_PyUsdHydra")

  /**
   * Where ``CameraUtil`` application bundle resources are located. */
  static let pyCameraUtil = pxrBundle("swift-usd_PyCameraUtil")

  /**
   * Where ``PxOsd`` application bundle resources are located. */
  static let pyPxOsd = pxrBundle("swift-usd_PyPxOsd")

  /**
   * Where ``Garch`` application bundle resources are located. */
  static let pyGarch = pxrBundle("swift-usd_PyGarch")

  /**
   * Where ``Glf`` application bundle resources are located. */
  static let pyGlf = pxrBundle("swift-usd_PyGlf")

  /**
   * Where ``GeomUtil`` application bundle resources are located. */
  static let pyGeomUtil = pxrBundle("swift-usd_PyGeomUtil")
}
