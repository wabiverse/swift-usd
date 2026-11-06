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

#if canImport(UsdLux)
  import UsdLux
#else
  import OpenUSD
#endif

private extension UsdLux
{
  /**
   * Private struct to hold the static
   * data for the UsdLux library. */
  struct StaticData: @unchecked Sendable
  {
    static let shared = StaticData()
    private init()
    {}

    let tokens = Pixar.UsdLuxTokensType()
  }
}

public extension UsdLux
{
  /**
   * # UsdLux.Tokens
   *
   * ## Overview
   *
   * Public, client facing api to access
   * the static UsdLux tokens. */
  enum Tokens: CaseIterable
  {
    case angular
    case automatic
    case collectionFilterLinkIncludeRoot
    case collectionLightLinkIncludeRoot
    case collectionShadowLinkIncludeRoot
    case consumeAndContinue
    case consumeAndHalt
    case cubeMapVerticalCross
    case filterLink
    case geometry
    case guideRadius
    case ignore
    case independent
    case inputsAngle
    case inputsColor
    case inputsColorTemperature
    case inputsDiffuse
    case inputsEnableColorTemperature
    case inputsExposure
    case inputsHeight
    case inputsIntensity
    case inputsLength
    case inputsNormalize
    case inputsRadius
    case inputsShadowColor
    case inputsShadowDistance
    case inputsShadowEnable
    case inputsShadowFalloff
    case inputsShadowFalloffGamma
    case inputsShapingConeAngle
    case inputsShapingConeSoftness
    case inputsShapingFocus
    case inputsShapingFocusTint
    case inputsShapingIesAngleScale
    case inputsShapingIesFile
    case inputsShapingIesNormalize
    case inputsSpecular
    case inputsTextureFile
    case inputsTextureFormat
    case inputsWidth
    case latlong
    case lightFilters
    case lightFilterShaderId
    case lightLink
    case lightList
    case lightListCacheBehavior
    case lightMaterialSyncMode
    case lightShaderId
    case materialGlowTintsLight
    case meshLight
    case mirroredBall
    case noMaterialResponse
    case orientToStageUpAxis
    case poleAxis
    case portals
    case scene
    case shadowLink
    case treatAsLine
    case treatAsPoint
    case volumeLight
    case Y
    case Z
    case boundableLightBase
    case cylinderLight
    case diskLight
    case distantLight
    case domeLight
    case domeLight_1
    case geometryLight
    case lightAPI
    case lightFilter
    case lightListAPI
    case listAPI
    case meshLightAPI
    case nonboundableLightBase
    case pluginLight
    case pluginLightFilter
    case portalLight
    case rectLight
    case shadowAPI
    case shapingAPI
    case sphereLight
    case volumeLightAPI

    public var token: Tf.Token
    {
      switch self
      {
        case .angular: StaticData.shared.tokens.angular
        case .automatic: StaticData.shared.tokens.automatic
        case .collectionFilterLinkIncludeRoot: StaticData.shared.tokens.collectionFilterLinkIncludeRoot
        case .collectionLightLinkIncludeRoot: StaticData.shared.tokens.collectionLightLinkIncludeRoot
        case .collectionShadowLinkIncludeRoot: StaticData.shared.tokens.collectionShadowLinkIncludeRoot
        case .consumeAndContinue: StaticData.shared.tokens.consumeAndContinue
        case .consumeAndHalt: StaticData.shared.tokens.consumeAndHalt
        case .cubeMapVerticalCross: StaticData.shared.tokens.cubeMapVerticalCross
        case .filterLink: StaticData.shared.tokens.filterLink
        case .geometry: StaticData.shared.tokens.geometry
        case .guideRadius: StaticData.shared.tokens.guideRadius
        case .ignore: StaticData.shared.tokens.ignore
        case .independent: StaticData.shared.tokens.independent
        case .inputsAngle: StaticData.shared.tokens.inputsAngle
        case .inputsColor: StaticData.shared.tokens.inputsColor
        case .inputsColorTemperature: StaticData.shared.tokens.inputsColorTemperature
        case .inputsDiffuse: StaticData.shared.tokens.inputsDiffuse
        case .inputsEnableColorTemperature: StaticData.shared.tokens.inputsEnableColorTemperature
        case .inputsExposure: StaticData.shared.tokens.inputsExposure
        case .inputsHeight: StaticData.shared.tokens.inputsHeight
        case .inputsIntensity: StaticData.shared.tokens.inputsIntensity
        case .inputsLength: StaticData.shared.tokens.inputsLength
        case .inputsNormalize: StaticData.shared.tokens.inputsNormalize
        case .inputsRadius: StaticData.shared.tokens.inputsRadius
        case .inputsShadowColor: StaticData.shared.tokens.inputsShadowColor
        case .inputsShadowDistance: StaticData.shared.tokens.inputsShadowDistance
        case .inputsShadowEnable: StaticData.shared.tokens.inputsShadowEnable
        case .inputsShadowFalloff: StaticData.shared.tokens.inputsShadowFalloff
        case .inputsShadowFalloffGamma: StaticData.shared.tokens.inputsShadowFalloffGamma
        case .inputsShapingConeAngle: StaticData.shared.tokens.inputsShapingConeAngle
        case .inputsShapingConeSoftness: StaticData.shared.tokens.inputsShapingConeSoftness
        case .inputsShapingFocus: StaticData.shared.tokens.inputsShapingFocus
        case .inputsShapingFocusTint: StaticData.shared.tokens.inputsShapingFocusTint
        case .inputsShapingIesAngleScale: StaticData.shared.tokens.inputsShapingIesAngleScale
        case .inputsShapingIesFile: StaticData.shared.tokens.inputsShapingIesFile
        case .inputsShapingIesNormalize: StaticData.shared.tokens.inputsShapingIesNormalize
        case .inputsSpecular: StaticData.shared.tokens.inputsSpecular
        case .inputsTextureFile: StaticData.shared.tokens.inputsTextureFile
        case .inputsTextureFormat: StaticData.shared.tokens.inputsTextureFormat
        case .inputsWidth: StaticData.shared.tokens.inputsWidth
        case .latlong: StaticData.shared.tokens.latlong
        case .lightFilters: StaticData.shared.tokens.lightFilters
        case .lightFilterShaderId: StaticData.shared.tokens.lightFilterShaderId
        case .lightLink: StaticData.shared.tokens.lightLink
        case .lightList: StaticData.shared.tokens.lightList
        case .lightListCacheBehavior: StaticData.shared.tokens.lightListCacheBehavior
        case .lightMaterialSyncMode: StaticData.shared.tokens.lightMaterialSyncMode
        case .lightShaderId: StaticData.shared.tokens.lightShaderId
        case .materialGlowTintsLight: StaticData.shared.tokens.materialGlowTintsLight
        case .meshLight: StaticData.shared.tokens.MeshLight
        case .mirroredBall: StaticData.shared.tokens.mirroredBall
        case .noMaterialResponse: StaticData.shared.tokens.noMaterialResponse
        case .orientToStageUpAxis: StaticData.shared.tokens.orientToStageUpAxis
        case .poleAxis: StaticData.shared.tokens.poleAxis
        case .portals: StaticData.shared.tokens.portals
        case .scene: StaticData.shared.tokens.scene
        case .shadowLink: StaticData.shared.tokens.shadowLink
        case .treatAsLine: StaticData.shared.tokens.treatAsLine
        case .treatAsPoint: StaticData.shared.tokens.treatAsPoint
        case .volumeLight: StaticData.shared.tokens.VolumeLight
        case .Y: StaticData.shared.tokens.Y
        case .Z: StaticData.shared.tokens.Z
        case .boundableLightBase: StaticData.shared.tokens.BoundableLightBase
        case .cylinderLight: StaticData.shared.tokens.CylinderLight
        case .diskLight: StaticData.shared.tokens.DiskLight
        case .distantLight: StaticData.shared.tokens.DistantLight
        case .domeLight: StaticData.shared.tokens.DomeLight
        case .domeLight_1: StaticData.shared.tokens.DomeLight_1
        case .geometryLight: StaticData.shared.tokens.GeometryLight
        case .lightAPI: StaticData.shared.tokens.LightAPI
        case .lightFilter: StaticData.shared.tokens.LightFilter
        case .lightListAPI: StaticData.shared.tokens.LightListAPI
        case .listAPI: StaticData.shared.tokens.ListAPI
        case .meshLightAPI: StaticData.shared.tokens.MeshLightAPI
        case .nonboundableLightBase: StaticData.shared.tokens.NonboundableLightBase
        case .pluginLight: StaticData.shared.tokens.PluginLight
        case .pluginLightFilter: StaticData.shared.tokens.PluginLightFilter
        case .portalLight: StaticData.shared.tokens.PortalLight
        case .rectLight: StaticData.shared.tokens.RectLight
        case .shadowAPI: StaticData.shared.tokens.ShadowAPI
        case .shapingAPI: StaticData.shared.tokens.ShapingAPI
        case .sphereLight: StaticData.shared.tokens.SphereLight
        case .volumeLightAPI: StaticData.shared.tokens.VolumeLightAPI
      }
    }
  }
}

public extension Tf.Token
{
  nonisolated(unsafe) static let angular = UsdLux.Tokens.angular.token
  nonisolated(unsafe) static let automatic = UsdLux.Tokens.automatic.token
  nonisolated(unsafe) static let collectionFilterLinkIncludeRoot = UsdLux.Tokens.collectionFilterLinkIncludeRoot.token
  nonisolated(unsafe) static let collectionLightLinkIncludeRoot = UsdLux.Tokens.collectionLightLinkIncludeRoot.token
  nonisolated(unsafe) static let collectionShadowLinkIncludeRoot = UsdLux.Tokens.collectionShadowLinkIncludeRoot.token
  nonisolated(unsafe) static let consumeAndContinue = UsdLux.Tokens.consumeAndContinue.token
  nonisolated(unsafe) static let consumeAndHalt = UsdLux.Tokens.consumeAndHalt.token
  nonisolated(unsafe) static let cubeMapVerticalCross = UsdLux.Tokens.cubeMapVerticalCross.token
  nonisolated(unsafe) static let filterLink = UsdLux.Tokens.filterLink.token
  nonisolated(unsafe) static let geometry = UsdLux.Tokens.geometry.token
  nonisolated(unsafe) static let guideRadius = UsdLux.Tokens.guideRadius.token
  nonisolated(unsafe) static let ignore = UsdLux.Tokens.ignore.token
  nonisolated(unsafe) static let independent = UsdLux.Tokens.independent.token
  nonisolated(unsafe) static let inputsAngle = UsdLux.Tokens.inputsAngle.token
  nonisolated(unsafe) static let inputsColor = UsdLux.Tokens.inputsColor.token
  nonisolated(unsafe) static let inputsColorTemperature = UsdLux.Tokens.inputsColorTemperature.token
  nonisolated(unsafe) static let inputsDiffuse = UsdLux.Tokens.inputsDiffuse.token
  nonisolated(unsafe) static let inputsEnableColorTemperature = UsdLux.Tokens.inputsEnableColorTemperature.token
  nonisolated(unsafe) static let inputsExposure = UsdLux.Tokens.inputsExposure.token
  nonisolated(unsafe) static let inputsHeight = UsdLux.Tokens.inputsHeight.token
  nonisolated(unsafe) static let inputsIntensity = UsdLux.Tokens.inputsIntensity.token
  nonisolated(unsafe) static let inputsLength = UsdLux.Tokens.inputsLength.token
  nonisolated(unsafe) static let inputsNormalize = UsdLux.Tokens.inputsNormalize.token
  nonisolated(unsafe) static let inputsRadius = UsdLux.Tokens.inputsRadius.token
  nonisolated(unsafe) static let inputsShadowColor = UsdLux.Tokens.inputsShadowColor.token
  nonisolated(unsafe) static let inputsShadowDistance = UsdLux.Tokens.inputsShadowDistance.token
  nonisolated(unsafe) static let inputsShadowEnable = UsdLux.Tokens.inputsShadowEnable.token
  nonisolated(unsafe) static let inputsShadowFalloff = UsdLux.Tokens.inputsShadowFalloff.token
  nonisolated(unsafe) static let inputsShadowFalloffGamma = UsdLux.Tokens.inputsShadowFalloffGamma.token
  nonisolated(unsafe) static let inputsShapingConeAngle = UsdLux.Tokens.inputsShapingConeAngle.token
  nonisolated(unsafe) static let inputsShapingConeSoftness = UsdLux.Tokens.inputsShapingConeSoftness.token
  nonisolated(unsafe) static let inputsShapingFocus = UsdLux.Tokens.inputsShapingFocus.token
  nonisolated(unsafe) static let inputsShapingFocusTint = UsdLux.Tokens.inputsShapingFocusTint.token
  nonisolated(unsafe) static let inputsShapingIesAngleScale = UsdLux.Tokens.inputsShapingIesAngleScale.token
  nonisolated(unsafe) static let inputsShapingIesFile = UsdLux.Tokens.inputsShapingIesFile.token
  nonisolated(unsafe) static let inputsShapingIesNormalize = UsdLux.Tokens.inputsShapingIesNormalize.token
  nonisolated(unsafe) static let inputsSpecular = UsdLux.Tokens.inputsSpecular.token
  nonisolated(unsafe) static let inputsTextureFile = UsdLux.Tokens.inputsTextureFile.token
  nonisolated(unsafe) static let inputsTextureFormat = UsdLux.Tokens.inputsTextureFormat.token
  nonisolated(unsafe) static let inputsWidth = UsdLux.Tokens.inputsWidth.token
  nonisolated(unsafe) static let latlong = UsdLux.Tokens.latlong.token
  nonisolated(unsafe) static let lightFilters = UsdLux.Tokens.lightFilters.token
  nonisolated(unsafe) static let lightFilterShaderId = UsdLux.Tokens.lightFilterShaderId.token
  nonisolated(unsafe) static let lightLink = UsdLux.Tokens.lightLink.token
  nonisolated(unsafe) static let lightList = UsdLux.Tokens.lightList.token
  nonisolated(unsafe) static let lightListCacheBehavior = UsdLux.Tokens.lightListCacheBehavior.token
  nonisolated(unsafe) static let lightMaterialSyncMode = UsdLux.Tokens.lightMaterialSyncMode.token
  nonisolated(unsafe) static let lightShaderId = UsdLux.Tokens.lightShaderId.token
  nonisolated(unsafe) static let materialGlowTintsLight = UsdLux.Tokens.materialGlowTintsLight.token
  nonisolated(unsafe) static let meshLight = UsdLux.Tokens.meshLight.token
  nonisolated(unsafe) static let mirroredBall = UsdLux.Tokens.mirroredBall.token
  nonisolated(unsafe) static let noMaterialResponse = UsdLux.Tokens.noMaterialResponse.token
  nonisolated(unsafe) static let orientToStageUpAxis = UsdLux.Tokens.orientToStageUpAxis.token
  nonisolated(unsafe) static let poleAxis = UsdLux.Tokens.poleAxis.token
  nonisolated(unsafe) static let portals = UsdLux.Tokens.portals.token
  nonisolated(unsafe) static let scene = UsdLux.Tokens.scene.token
  nonisolated(unsafe) static let shadowLink = UsdLux.Tokens.shadowLink.token
  nonisolated(unsafe) static let treatAsLine = UsdLux.Tokens.treatAsLine.token
  nonisolated(unsafe) static let treatAsPoint = UsdLux.Tokens.treatAsPoint.token
  nonisolated(unsafe) static let volumeLight = UsdLux.Tokens.volumeLight.token
  nonisolated(unsafe) static let Y = UsdLux.Tokens.Y.token
  nonisolated(unsafe) static let Z = UsdLux.Tokens.Z.token
  nonisolated(unsafe) static let boundableLightBase = UsdLux.Tokens.boundableLightBase.token
  nonisolated(unsafe) static let cylinderLight = UsdLux.Tokens.cylinderLight.token
  nonisolated(unsafe) static let diskLight = UsdLux.Tokens.diskLight.token
  nonisolated(unsafe) static let distantLight = UsdLux.Tokens.distantLight.token
  nonisolated(unsafe) static let domeLight = UsdLux.Tokens.domeLight.token
  nonisolated(unsafe) static let domeLight_1 = UsdLux.Tokens.domeLight_1.token
  nonisolated(unsafe) static let geometryLight = UsdLux.Tokens.geometryLight.token
  nonisolated(unsafe) static let lightAPI = UsdLux.Tokens.lightAPI.token
  nonisolated(unsafe) static let lightFilter = UsdLux.Tokens.lightFilter.token
  nonisolated(unsafe) static let lightListAPI = UsdLux.Tokens.lightListAPI.token
  nonisolated(unsafe) static let listAPI = UsdLux.Tokens.listAPI.token
  nonisolated(unsafe) static let meshLightAPI = UsdLux.Tokens.meshLightAPI.token
  nonisolated(unsafe) static let nonboundableLightBase = UsdLux.Tokens.nonboundableLightBase.token
  nonisolated(unsafe) static let pluginLight = UsdLux.Tokens.pluginLight.token
  nonisolated(unsafe) static let pluginLightFilter = UsdLux.Tokens.pluginLightFilter.token
  nonisolated(unsafe) static let portalLight = UsdLux.Tokens.portalLight.token
  nonisolated(unsafe) static let rectLight = UsdLux.Tokens.rectLight.token
  nonisolated(unsafe) static let shadowAPI = UsdLux.Tokens.shadowAPI.token
  nonisolated(unsafe) static let shapingAPI = UsdLux.Tokens.shapingAPI.token
  nonisolated(unsafe) static let sphereLight = UsdLux.Tokens.sphereLight.token
  nonisolated(unsafe) static let volumeLightAPI = UsdLux.Tokens.volumeLightAPI.token
}
