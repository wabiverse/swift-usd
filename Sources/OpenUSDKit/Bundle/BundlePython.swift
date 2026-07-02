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

public enum BundlePython: CaseIterable
{
  case pyTf
  case pyPlug
  case pyTrace
  case pyWork
  case pyGf
  case pyVt
  case pyAr
  case pyKind
  case pySdf
  case pyPcp
  case pyUsd
  case pyNdr
  case pySdr
  case pySdrOsl
  case pyUsdGeom
  case pyUsdShade
  case pyUsdShaders
  case pyUsdLod
  case pyUsdLux
  case pyUsdHydra
  case pyUsdAbc
  case pyUsdDraco
  case pyUsdMedia
  case pyUsdMtlx
  case pyUsdPhysics
  case pyUsdProc
  case pyUsdRender
  case pyUsdRi
  case pyUsdSkel
  case pyUsdUI
  case pyUsdUtils
  case pyUsdVol
  case pyCameraUtil
  case pyPxOsd
  case pyGarch
  case pyGlf
  case pyGeomUtil

  public var resourcePath: String?
  {
    switch self
    {
      case .pyTf: Bundle.pyTf?.resourcePath
      case .pyPlug: Bundle.pyPlug?.resourcePath
      case .pyTrace: Bundle.pyTrace?.resourcePath
      case .pyWork: Bundle.pyWork?.resourcePath
      case .pyGf: Bundle.pyGf?.resourcePath
      case .pyVt: Bundle.pyVt?.resourcePath
      case .pyAr: Bundle.pyAr?.resourcePath
      case .pyKind: Bundle.pyKind?.resourcePath
      case .pySdf: Bundle.pySdf?.resourcePath
      case .pyPcp: Bundle.pyPcp?.resourcePath
      case .pyUsd: Bundle.pyUsd?.resourcePath
      case .pyNdr: Bundle.pyNdr?.resourcePath
      case .pySdr: Bundle.pySdr?.resourcePath
      case .pySdrOsl: Bundle.pySdrOsl?.resourcePath
      case .pyUsdGeom: Bundle.pyUsdGeom?.resourcePath
      case .pyUsdShade: Bundle.pyUsdShade?.resourcePath
      case .pyUsdShaders: Bundle.pyUsdShaders?.resourcePath
      case .pyUsdLod: Bundle.pyUsdLod?.resourcePath
      case .pyUsdLux: Bundle.pyUsdLux?.resourcePath
      case .pyUsdHydra: Bundle.pyUsdHydra?.resourcePath
      case .pyUsdAbc: Bundle.pyUsdAbc?.resourcePath
      case .pyUsdDraco: Bundle.pyUsdDraco?.resourcePath
      case .pyUsdMedia: Bundle.pyUsdMedia?.resourcePath
      case .pyUsdMtlx: Bundle.pyUsdMtlx?.resourcePath
      case .pyUsdPhysics: Bundle.pyUsdPhysics?.resourcePath
      case .pyUsdProc: Bundle.pyUsdProc?.resourcePath
      case .pyUsdRender: Bundle.pyUsdRender?.resourcePath
      case .pyUsdRi: Bundle.pyUsdRi?.resourcePath
      case .pyUsdSkel: Bundle.pyUsdSkel?.resourcePath
      case .pyUsdUI: Bundle.pyUsdUI?.resourcePath
      case .pyUsdUtils: Bundle.pyUsdUtils?.resourcePath
      case .pyUsdVol: Bundle.pyUsdVol?.resourcePath
      case .pyCameraUtil: Bundle.pyCameraUtil?.resourcePath
      case .pyPxOsd: Bundle.pyPxOsd?.resourcePath
      case .pyGarch: Bundle.pyGarch?.resourcePath
      case .pyGlf: Bundle.pyGlf?.resourcePath
      case .pyGeomUtil: Bundle.pyGeomUtil?.resourcePath
    }
  }
}
