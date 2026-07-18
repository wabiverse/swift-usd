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

public enum BundleFramework: CaseIterable
{
  case ar
  case sdf
  case usd
  case ndr
  case usdGeom
  case usdShade
  case usdShaders
  case usdLod
  case usdLux
  case usdHydra
  case sdrOsl
  case usdAbc
  case usdDraco
  case usdMedia
  case usdMtlx
  case usdPhysics
  case usdProc
  case usdRender
  case usdRi
  case usdSkel
  case usdUI
  case usdVol
  case hd
  case hgiMetal
  case hgiVulkan
  case hgiGL
  case hdSi
  case hdSt
  case hdStorm
  case hdx
  case hdGp
  case hio
  case hioAVIF
  case hioImageIO
  case hioOIIO
  case hioOpenEXR
  case hioOpenVDB
  case glf
  case usdImaging
  case usdImagingGL

  public var resourcePath: String?
  {
    switch self
    {
      case .ar: Bundle.ar?.resourcePath
      case .sdf: Bundle.sdf?.resourcePath
      case .usd: Bundle.usd?.resourcePath
      case .ndr: Bundle.ndr?.resourcePath
      case .usdGeom: Bundle.usdGeom?.resourcePath
      case .usdShade: Bundle.usdShade?.resourcePath
      case .usdShaders: Bundle.usdShaders?.resourcePath
      case .usdLod: Bundle.usdLod?.resourcePath
      case .usdLux: Bundle.usdLux?.resourcePath
      case .usdHydra: Bundle.usdHydra?.resourcePath
      case .sdrOsl: Bundle.sdrOsl?.resourcePath
      case .usdAbc: Bundle.usdAbc?.resourcePath
      case .usdDraco: Bundle.usdDraco?.resourcePath
      case .usdMedia: Bundle.usdMedia?.resourcePath
      case .usdMtlx: Bundle.usdMtlx?.resourcePath
      case .usdPhysics: Bundle.usdPhysics?.resourcePath
      case .usdProc: Bundle.usdProc?.resourcePath
      case .usdRender: Bundle.usdRender?.resourcePath
      case .usdRi: Bundle.usdRi?.resourcePath
      case .usdSkel: Bundle.usdSkel?.resourcePath
      case .usdUI: Bundle.usdUI?.resourcePath
      case .usdVol: Bundle.usdVol?.resourcePath
      case .hd: Bundle.hd?.resourcePath
      case .hgiMetal: Bundle.hgiMetal?.resourcePath
      case .hgiVulkan: Bundle.hgiVulkan?.resourcePath
      case .hgiGL: Bundle.hgiGL?.resourcePath
      case .hdSi: Bundle.hdSi?.resourcePath
      case .hdSt: Bundle.hdSt?.resourcePath
      case .hdStorm: Bundle.hdStorm?.resourcePath
      case .hdx: Bundle.hdx?.resourcePath
      case .hdGp: Bundle.hdGp?.resourcePath
      case .hio: Bundle.hio?.resourcePath
      case .hioAVIF: Bundle.hioAVIF?.resourcePath
      case .hioImageIO: Bundle.hioImageIO?.resourcePath
      case .hioOIIO: Bundle.hioOIIO?.resourcePath
      case .hioOpenEXR: Bundle.hioOpenEXR?.resourcePath
      case .hioOpenVDB: Bundle.hioOpenVDB?.resourcePath
      case .glf: Bundle.glf?.resourcePath
      case .usdImaging: Bundle.usdImaging?.resourcePath
      case .usdImagingGL: Bundle.usdImagingGL?.resourcePath
    }
  }
}
