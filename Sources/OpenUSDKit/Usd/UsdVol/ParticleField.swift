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

#if canImport(UsdVol)
  import UsdVol
#else
  import OpenUSD
#endif
import simd

public typealias UsdVolParticleField3DGaussianSplat = Pixar.UsdVolParticleField3DGaussianSplat

public extension UsdVol
{
  typealias ParticleField3DGaussianSplat = UsdVolParticleField3DGaussianSplat
}

public extension UsdVol.ParticleField3DGaussianSplat
{
  @discardableResult
  static func define(_ stage: UsdStage, path: Sdf.Path) -> UsdVol.ParticleField3DGaussianSplat
  {
    UsdVol.ParticleField3DGaussianSplat.Define(Overlay.TfWeakPtr(stage), path)
  }

  @discardableResult
  static func define(_ stage: UsdStage, path: String) -> UsdVol.ParticleField3DGaussianSplat
  {
    UsdVol.ParticleField3DGaussianSplat.define(stage, path: .init(path))
  }

  /// Writes a whole splat cloud, colors are linear
  /// rgb written as degree zero spherical harmonics.
  @discardableResult
  func set(positions: [SIMD3<Float>],
           orientations: [simd_quatf],
           scales: [SIMD3<Float>],
           opacities: [Float],
           colors: [SIMD3<Float>],
           time: Pixar.UsdTimeCode = Pixar.UsdTimeCode.Default()) -> Bool
  {
    let p: Pixar.VtVec3fArray = positions.map { Pixar.GfVec3f($0.x, $0.y, $0.z) }
      .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }
    let q: Pixar.VtQuatfArray = orientations.map { Pixar.GfQuatf($0.real, $0.imag.x, $0.imag.y, $0.imag.z) }
      .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }
    let s: Pixar.VtVec3fArray = scales.map { Pixar.GfVec3f($0.x, $0.y, $0.z) }
      .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }
    let o: Pixar.VtFloatArray = opacities
      .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }

    // the band zero coefficient that gives back
    // a color once the renderer adds one half.
    let dc = 1 / Float(0.28209479177387814)
    let sh: Pixar.VtVec3fArray = colors.map
    { c in
      let k = (c - 0.5) * dc
      return Pixar.GfVec3f(k.x, k.y, k.z)
    }
    .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }

    let any = Pixar.VtValue()
    var ok = CreatePositionsAttr(any, false).Set(p, time)
    ok = CreateOrientationsAttr(any, false).Set(q, time) && ok
    ok = CreateScalesAttr(any, false).Set(s, time) && ok
    ok = CreateOpacitiesAttr(any, false).Set(o, time) && ok
    ok = CreateRadianceSphericalHarmonicsDegreeAttr(any, false).Set(Int32(0), time) && ok
    ok = CreateRadianceSphericalHarmonicsCoefficientsAttr(any, false).Set(sh, time) && ok

    var extent = Pixar.VtVec3fArray()
    if !positions.isEmpty
    {
      var lo = positions[0], hi = positions[0]
      for (i, point) in positions.enumerated()
      {
        let r = simd_reduce_max(i < scales.count ? scales[i] : .zero) * 3
        lo = simd_min(lo, point - r)
        hi = simd_max(hi, point + r)
      }

      extent = [Pixar.GfVec3f(lo.x, lo.y, lo.z), Pixar.GfVec3f(hi.x, hi.y, hi.z)]
        .withUnsafeBufferPointer { Overlay.vtArray($0.baseAddress, $0.count) }
    }

    return CreateExtentAttr(any, false).Set(extent, time) && ok
  }
}
