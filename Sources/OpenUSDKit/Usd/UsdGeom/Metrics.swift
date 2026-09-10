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

#if canImport(UsdGeom)
  import UsdGeom
#else
  import OpenUSD
#endif

public typealias UsdGeomLinearUnits = Pixar.UsdGeomLinearUnits

public extension UsdGeom
{
  typealias LinearUnits = UsdGeomLinearUnits
}

public extension UsdGeom
{
  /// Fetch and return `stage`'s upAxis. If unauthored, will return the
  /// value provided by UsdGeomGetFallbackUpAxis(). Exporters, however,
  /// are strongly encouraged to always set the upAxis for every USD file
  /// they create.
  static func getUpAxis(for stage: UsdStage) -> Tf.Token
  {
    Pixar.UsdGeomGetStageUpAxis(Overlay.TfWeakPtr(stage))
  }
  
  /// Set `stage`'s upAxis to `axis`, which must be one of `.y` or `.z`. The
  /// stage's UsdEditTarget must be either its root layer or session layer.
  /// Returns `true` if upAxis was successfully set.
  static func setUpAxis(for stage: UsdStage, to axis: Tf.Token) -> Bool
  {
    Pixar.UsdGeomSetStageUpAxis(Overlay.TfWeakPtr(stage), axis)
  }

  /// The site-level fallback up axis, `.y` unless
  /// overridden by a plugInfo.json's upAxis.
  static func getFallbackUpAxis() -> Tf.Token
  {
    Pixar.UsdGeomGetFallbackUpAxis()
  }

  /// Return `stage`'s authored metersPerUnit, or 0.01 if unauthored.
  static func getMetersPerUnit(for stage: UsdStage) -> Double
  {
    Pixar.UsdGeomGetStageMetersPerUnit(Overlay.TfWeakPtr(stage))
  }

  /// Author `stage`'s `metersPerUnit`. The stage's UsdEditTarget must be
  /// either its root layer or session layer. Returns `true` on success.
  static func setMetersPerUnit(for stage: UsdStage, to metersPerUnit: Double) -> Bool
  {
    Pixar.UsdGeomSetStageMetersPerUnit(Overlay.TfWeakPtr(stage), metersPerUnit)
  }
  
  /// Return whether `stage` has an authored metersPerUnit.
  static func hasAuthoredMetersPerUnit(for stage: UsdStage) -> Bool
  {
    Pixar.UsdGeomStageHasAuthoredMetersPerUnit(Overlay.TfWeakPtr(stage))
  }

  /// Returns `true` if `authoredUnits` and `standardUnits` are within
  /// relative `epsilon` of each other, `false` if either is zero or negative.
  static func linearUnitsAre(_ authoredUnits: Double, _ standardUnits: Double, epsilon: Double = 1e-5) -> Bool
  {
    Pixar.UsdGeomLinearUnitsAre(authoredUnits, standardUnits, epsilon)
  }
}
