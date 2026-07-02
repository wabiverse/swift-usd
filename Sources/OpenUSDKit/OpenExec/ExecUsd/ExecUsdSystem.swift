#if canImport(ExecUsd)
import ExecUsd
#else
import OpenUSD
#endif

public typealias ExecUsdRequest = Pixar.ExecUsdRequest
public typealias ExecUsdValueKey = Pixar.ExecUsdValueKey
public typealias ExecUsdCacheView = Pixar.ExecUsdCacheView

#if canImport(ExecUsd)
public typealias ExecUsdSystem = Pixar.ExecUsdSystem

public extension ExecUsd
{
  typealias System = ExecUsdSystem
}

public extension ExecUsd.System
{
  /// Creates an `ExecUsdSystem` that owns and evaluates the given stage.
  ///
  /// Delegates to the C++ `ExecUsdSystem(const UsdStageRefPtr &)` overload.
  /// The overlay can produce a non-const `UsdStageRefPtr` (via
  /// `Overlay.TfRefPtr`) but not a `UsdStageConstRefPtr`, so the C++ side
  /// performs the non-const-to-const `TfRefPtr` conversion.
  static func create(stage: UsdStage) -> ExecUsd.System
  {
    ExecUsd.System.Create(Overlay.TfRefPtr(stage))
  }
}
#endif
