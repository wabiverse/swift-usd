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

public extension Hydra.RenderEngine
{
  /// What a viewport pick landed on, the gprim under the cursor,
  /// and, when that gprim is drawn by an instancer, which instance
  /// it was.
  struct PickResult
  {
    /// The gprim selected by the pick.
    public let primPath: SdfPath
    /// The point instancer of that gprim, or an empty path if it is not
    /// instanced. With an aggregating scene this is the prim instancer,
    /// and ``instanceIndex`` is the cell.
    public let instancerPath: SdfPath
    /// The instance index within ``instancerPath``, or `-1` when not instanced.
    public let instanceIndex: Int
    /// The hit position in world space.
    public let worldPoint: Gf.Vec3d

    /// Whether the pick resolved to an instance of a prim instancer.
    public var isInstance: Bool { !instancerPath.IsEmpty() }
  }

  /// All picking/selection state.
  struct PickState
  {
    var pendingSelection: (point: CGPoint, viewSize: CGSize)?
    var selectedPrimId: Int32 = -1
    var selectedInstanceId: Int32 = -1
    var selectionUsesGroup: Bool = false
    var selectionGroup: [Int32] = []
    var selectionGroupVersion: Int = 0
    var selectionSelectAll: Bool = false
    var selectionModelLUT: [Int32] = []
    var selectionModelLUTVersion: Int = 0
    var primIdPathCache: [(id: Int32, path: SdfPath)]?
    var lastPickedPath: SdfPath?
    /// The prim the outline covers, its bounds frame the outline region.
    var selectionRoot: SdfPath?
    var selectionBounds: (key: String, time: Double, min: SIMD3<Double>, max: SIMD3<Double>)?
  }

  /// A click waiting for the renderer to read the id AOVs under it.
  var pendingSelection: (point: CGPoint, viewSize: CGSize)?
  {
    get { pickState.pendingSelection }
    set { pickState.pendingSelection = newValue }
  }

  /// The id AOV values under the last resolved click, or `-1`.
  var selectedPrimId: Int32
  {
    get { pickState.selectedPrimId }
    set { pickState.selectedPrimId = newValue }
  }

  var selectedInstanceId: Int32
  {
    get { pickState.selectedInstanceId }
    set { pickState.selectedInstanceId = newValue }
  }

  /// Set when the last pick resolved to a model (a non-instanced prim): the
  /// outline then covers every prim in that model via `selectionGroup` rather
  /// than the single (primId, instanceId) pair.
  var selectionUsesGroup: Bool
  {
    get { pickState.selectionUsesGroup }
    set { pickState.selectionUsesGroup = newValue }
  }

  /// `1` at index `primId` for each prim id in the picked model, else `0`.
  /// The outline mask kernel tests membership here. Empty when not a model
  /// pick.
  var selectionGroup: [Int32]
  {
    get { pickState.selectionGroup }
    set { pickState.selectionGroup = newValue }
  }

  /// Bumped whenever `selectionGroup` changes,
  /// so the renderer rebuilds its GPU copy only
  /// on a new model pick.
  var selectionGroupVersion: Int
  {
    get { pickState.selectionGroupVersion }
    set { pickState.selectionGroupVersion = newValue }
  }

  /// Set when everything is selected (`A`): the outline then
  /// covers every prim, ignoring the id-pair and group state.
  var selectionSelectAll: Bool
  {
    get { pickState.selectionSelectAll }
    set { pickState.selectionSelectAll = newValue }
  }

  /// Maps each rprim's id-AOV value to its model id (a small sequential
  /// id per enclosing model, 0 = none), so select-all can outline every
  /// object individually - the outline mask kernel seeds a border when
  /// this changes. Built once, alongside the internal id -> path cache.
  var selectionModelLUT: [Int32] { pickState.selectionModelLUT }
  /// Bumped when `selectionModelLUT` is (re)built, so the
  /// renderer rebuilds its GPU copy only when needed.
  var selectionModelLUTVersion: Int { pickState.selectionModelLUTVersion }

  /// The gprim of the most recent successful pick,
  /// so "frame selected" has a target. Cleared on
  /// a miss.
  var lastPickedPath: SdfPath? { pickState.lastPickedPath }

  /// Intersects the scene under `point` on the frame queue and hands the
  /// result to `completion` on the main thread, the queue the viewport
  /// invokes ``onPick`` on. Safe to call from any thread.
  func pick(at point: CGPoint, viewSize: CGSize, completion: @escaping @Sendable (PickResult?) -> Void)
  {
    performOnFrameQueue
    {
      let result = self.pick(at: point, viewSize: viewSize)
      DispatchQueue.main.async { completion(result) }
    }
  }

  /// Intersects the scene under `point` and returns what was hit, or `nil`.
  ///
  /// `point` is in the view's own coordinates: origin bottom-left, y up, to
  /// match AppKit. The current view camera is reused and narrowed to a few
  /// pixels around the point, so a click selects what is under the cursor
  /// rather than everything along the ray.
  private func pick(at point: CGPoint, viewSize: CGSize) -> PickResult?
  {
    guard viewSize.width > 0, viewSize.height > 0 else { return nil }

    // ask the renderer to read the id AOVs under this click
    // (hit or miss: a miss reads background and clears the
    // outline).
    pickState.pendingSelection = (point, viewSize)

    let cameraTransform = viewCamera.getTransform()
    let frustum = computeFrustum(cameraTransform: cameraTransform,
                                 viewSize: viewSize,
                                 camera: viewCamera)

    // view point -> normalized device coords in [-1, 1].
    let ndcX = (Double(point.x) / Double(viewSize.width)) * 2.0 - 1.0
    let ndcY = (Double(point.y) / Double(viewSize.height)) * 2.0 - 1.0

    // a few extra pixels of padding, so the pick has a forgiving target.
    let pickRadius = 6.0
    let size = Gf.Vec2d(pickRadius / Double(viewSize.width),
                        pickRadius / Double(viewSize.height))

    let pickFrustum = frustum.ComputeNarrowedFrustum(Gf.Vec2d(ndcX, ndcY), size)
    let viewMatrix = pickFrustum.computeViewMatrix()
    let projMatrix = pickFrustum.computeProjectionMatrix()

    var params = UsdImagingGL.RenderParams()
    // the same timecode the frame was drawn at, so
    // the pick tests the pose that is actually on
    // screen (see `lastRenderTimeCode`).
    params.frame = Usd.TimeCode(lastRenderTimeCode)
    params.showGuides = true
    params.showRender = true
    params.showProxy = true

    var hitPoint = Gf.Vec3d()
    var hitNormal = Gf.Vec3d()
    var primPath = SdfPath()
    var instancerPath = SdfPath()
    var instanceIndex: Int32 = -1

    let hit = engine.TestIntersection(viewMatrix,
                                      projMatrix,
                                      stage.getPseudoRoot(),
                                      params,
                                      &hitPoint,
                                      &hitNormal,
                                      &primPath,
                                      &instancerPath,
                                      &instanceIndex,
                                      nil)

    // drive hydra's own selection so the hit lights up
    // on the next frame. a miss clears it, so clicking
    // empty space deselects.
    engine.ClearSelected()

    // the model-scope and select-all outlines use these flags,
    // reset them each pick so a stale selection never lingers
    // (a miss or instance pick clears).
    pickState.selectionUsesGroup = false
    pickState.selectionSelectAll = false

    guard hit else
    {
      pickState.selectionGroup = []
      pickState.lastPickedPath = nil
      pickState.selectionRoot = nil
      return nil
    }

    pickState.lastPickedPath = primPath

    if !instancerPath.IsEmpty()
    {
      // an instanced hit highlights the specific instance
      // that was drawn, which, on the aggregating path, is
      // the cell the pick resolved to - kept individually
      // selectable via (primId, instanceId).
      engine.AddSelected(instancerPath, instanceIndex)
      pickState.selectionRoot = instancerPath
    }
    else
    {
      // a plain prim outlines its whole model, so the
      // outline reads as a per-object selection rather
      // than a single mesh.
      selectModel(root: modelRoot(of: primPath))
      engine.AddSelected(primPath, -1)
    }

    return PickResult(primPath: primPath,
                      instancerPath: instancerPath,
                      instanceIndex: Int(instanceIndex),
                      worldPoint: hitPoint)
  }

  /// A click falls back to the selected prim ID. Runs
  /// on the frame queue once the renderer has read them.
  func resolvePickFromAovs(primId: Int32, instanceId: Int32)
  {
    guard
      pickState.lastPickedPath == nil,
      primId >= 0,
      let path = engine.decodePrimPath(primId: primId, instanceId: instanceId)
    else { return }

    pickState.lastPickedPath = path
    selectModel(root: modelRoot(of: path))
    engine.AddSelected(path, -1)
  }

  /// Where the selection's outline can land in a `width` x `height` AOV
  /// (row 0 at the bottom), as origin.xy, size.xy padded by `margin`. The
  /// whole AOV when the selection's bounds are unknown, empty when it is
  /// off screen. Runs on the frame queue.
  func selectionRegion(width: Int, height: Int, margin: Int) -> SIMD4<Int32>
  {
    let full = SIMD4<Int32>(0, 0, Int32(width), Int32(height))
    guard
      !pickState.selectionSelectAll,
      let root = pickState.selectionRoot,
      let m = lastViewProjection,
      let bounds = selectionBounds(root)
    else { return full }

    var lo = SIMD2<Double>(repeating: .infinity)
    var hi = SIMD2<Double>(repeating: -.infinity)
    for corner in 0 ..< 8
    {
      let p = SIMD3(corner & 1 != 0 ? bounds.max.x : bounds.min.x,
                    corner & 2 != 0 ? bounds.max.y : bounds.min.y,
                    corner & 4 != 0 ? bounds.max.z : bounds.min.z)

      // row vector times the row major world to clip transform.
      let clip = (0 ..< 4).map { p.x * m[$0] + p.y * m[4 + $0] + p.z * m[8 + $0] + m[12 + $0] }
      // a corner behind the eye can project anywhere.
      guard clip[3] > 1e-6 else { return full }

      let ndc = SIMD2(clip[0], clip[1]) / clip[3]
      lo = pointwiseMin(lo, ndc)
      hi = pointwiseMax(hi, ndc)
    }

    let size = SIMD2(Double(width), Double(height))
    let x0 = max(Int(((lo.x * 0.5 + 0.5) * size.x).rounded(.down)) - margin, 0)
    let y0 = max(Int(((lo.y * 0.5 + 0.5) * size.y).rounded(.down)) - margin, 0)
    let x1 = min(Int(((hi.x * 0.5 + 0.5) * size.x).rounded(.up)) + margin, width)
    let y1 = min(Int(((hi.y * 0.5 + 0.5) * size.y).rounded(.up)) + margin, height)
    guard x1 > x0, y1 > y0 else { return .zero }
    return SIMD4(Int32(x0), Int32(y0), Int32(x1 - x0), Int32(y1 - y0))
  }

  /// The world bounds of `root` at the drawn time, cached until either changes.
  private func selectionBounds(_ root: SdfPath) -> (min: SIMD3<Double>, max: SIMD3<Double>)?
  {
    let key = root.string
    if let cached = pickState.selectionBounds, cached.key == key, cached.time == lastRenderTimeCode
    {
      return (cached.min, cached.max)
    }

    var bboxCache = computeBBoxCache(includeRender: true, at: lastRenderTimeCode)
    let bbox = bboxCache.ComputeWorldBound(stage.GetPrimAtPath(root))
    guard !isInfiniteBBox(bbox) else { return nil }
    let range = bbox.ComputeAlignedRange()
    guard !range.IsEmpty() else { return nil }

    #if canImport(Gf)
      let lo = range.GetMin().pointee, hi = range.GetMax().pointee
    #else
      let lo = range.GetMin(), hi = range.GetMax()
    #endif
    let bounds = (min: SIMD3(lo[0], lo[1], lo[2]), max: SIMD3(hi[0], hi[1], hi[2]))
    pickState.selectionBounds = (key, lastRenderTimeCode, bounds.min, bounds.max)
    return bounds
  }

  /// The enclosing model of `path` - the nearest ancestor (or the prim itself)
  /// that is a model but not a group, (i.e. a component, matching usdview's model
  /// pick mode). Falls back to `path` when the prim is not inside a model, so the
  /// outline still covers at least the picked prim.
  private func modelRoot(of path: SdfPath) -> SdfPath
  {
    var prim = stage.GetPrimAtPath(path)
    guard prim.IsValid() else { return path }

    var root: SdfPath?
    while prim.IsValid(), !prim.IsPseudoRoot()
    {
      if prim.IsModel(), !prim.IsGroup() { root = prim.GetPath() }
      prim = prim.GetParent()
    }
    return root ?? path
  }

  /// Every rprim id paired with its scene path, built once and reused. rprim
  /// ids are assigned densely from 1, so this walks them decoding to paths
  /// and stops after a long run of gaps. Returns empty when the decode is
  /// unavailable.
  private func ensurePrimIdPathCache() -> [(id: Int32, path: SdfPath)]
  {
    if let cache = pickState.primIdPathCache { return cache }

    var cache: [(id: Int32, path: SdfPath)] = []
    var misses = 0
    var id: Int32 = 1
    while misses < 1024, id < 1_000_000
    {
      if let path = engine.decodePrimPath(primId: id, instanceId: -1)
      {
        cache.append((id: id, path: path)); misses = 0
      }
      else { misses += 1 }
      id += 1
    }
    pickState.primIdPathCache = cache
    return cache
  }

  /// Flags every rprim id under `root` for the outline. Leaves the selection
  /// single-prim (via `selectedPrimId`) when the model has no resolved ids.
  /// (e.g. the decode is unavailable, so this degrades rather than clears).
  private func selectModel(root: SdfPath)
  {
    pickState.selectionRoot = root
    let cache = ensurePrimIdPathCache()
    guard let maxId = cache.map({ $0.id }).max() else { return }

    var lut = [Int32](repeating: 0, count: Int(maxId) + 1)
    for entry in cache where entry.path.HasPrefix(root)
    {
      lut[Int(entry.id)] = 1
    }

    pickState.selectionGroup = lut
    pickState.selectionUsesGroup = true
    pickState.selectionGroupVersion += 1
  }

  /// Discards the cached id -> path map, forcing a rebuild
  /// on the next model pick. Called after the stage's rprim
  /// topology changes. Safe to call from any thread.
  func invalidateSelectionGroupCache()
  {
    performOnFrameQueue
    {
      self.pickState.primIdPathCache = nil
      self.pickState.selectionModelLUT = []
    }
  }

  /// Selects every prim (`A`), outlining each object individually.
  /// Safe to call from any thread.
  func selectAll()
  {
    performOnFrameQueue
    {
      self.ensureModelLUT()
      self.pickState.selectionSelectAll = true
      self.pickState.selectionUsesGroup = false
      self.pickState.selectionGroup = []
    }
  }

  /// Builds the primId -> model-id table once: every rprim is mapped
  /// to a small sequential id for its enclosing model, so select-all
  /// can tell objects apart. Empty when the decode is unavailable.
  private func ensureModelLUT()
  {
    guard pickState.selectionModelLUT.isEmpty else { return }

    let cache = ensurePrimIdPathCache()
    guard let maxId = cache.map({ $0.id }).max() else { return }

    // the model id is the model root path's hash (0 reserved for background);
    // the mask kernel only compares labels for equality, so distinct values
    // per model are all that matters.
    var lut = [Int32](repeating: 0, count: Int(maxId) + 1)
    for entry in cache
    {
      var modelId = Int32(truncatingIfNeeded: modelRoot(of: entry.path).GetHash())
      if modelId == 0 { modelId = 1 }
      lut[Int(entry.id)] = modelId
    }

    pickState.selectionModelLUT = lut
    pickState.selectionModelLUTVersion += 1
  }

  /// Clears the current selection and its outline.
  /// The keyboard equivalent of clicking empty
  /// space (`Alt+A` / deselect all). Safe to call
  /// from any thread.
  func clearSelection()
  {
    performOnFrameQueue
    {
      self.pickState.selectedPrimId = -1
      self.pickState.selectedInstanceId = -1
      self.pickState.selectionUsesGroup = false
      self.pickState.selectionSelectAll = false
      self.pickState.selectionGroup = []
      self.pickState.lastPickedPath = nil
      self.pickState.selectionRoot = nil
      self.engine.ClearSelected()
    }
  }
}

extension Hydra.RenderEngine.PickResult: @unchecked Sendable {}
