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

#if !canImport(Gf)
import OpenUSD
public typealias GfVec3d = pxrInternal_v0_26_8__pxrReserved__.GfVec3d
#endif

public extension Hydra
{
  /// An orbit-style navigation camera.
  class Camera
  {
    private let isZUp: Bool

    /// The underlying camera this orbit controller drives.
    public var gfCamera = Gf.Camera()

    /// Orbit rotation around `focus`, in degrees (Z, then X, then Y).
    public var rotation = Pixar.GfVec3d(0.0)
    /// The point the camera orbits around and looks at.
    public var focus = Pixar.GfVec3d(0.0)
    /// Distance from `focus` to the camera position.
    public var distance = 50.0

    /// Explicit orthographic window (left/bottom/near, right/top/far),
    /// used only when `gfCamera.projection` is orthographic, set from
    /// an authored USD Camera's own computed frustum planes.
    public var leftBottomNear = Pixar.GfVec3d()
    public var rightTopFar = Pixar.GfVec3d()
    public var scaleViewport = 1.0

    /// Explicit near-clip override, in world units.
    /// If `nil` (the default), fits the near plane
    /// to the loaded stage bounds instead.
    public var nearClipOverride: Double?
    /// Explicit far-clip override, in world units.
    /// If `nil` (the default), fits the far plane
    /// to the loaded stage bounds instead.
    public var farClipOverride: Double?

    public var position = Pixar.GfVec3d()
    public var standardFocalLength = Double()
    public var scaleBias = Double()

    public init(isZUp: Bool)
    {
      self.isZUp = isZUp
      rotation = Pixar.GfVec3d(0.0)
      focus = Pixar.GfVec3d(0.0)
      distance = 50.0
      scaleViewport = 1.0
    }

    public func getTransform() -> GfMatrix4d
    {
      let gfRotation = getRotation()
      var cameraTransform = GfMatrix4d(1.0)

      var gfMatrix1 = GfMatrix4d()
      var gfMatrix2 = GfMatrix4d()
      var gfMatrix3 = GfMatrix4d()

      cameraTransform =
        gfMatrix1.SetTranslate(Pixar.GfVec3d(0.0, 0.0, distance)).pointee *
        gfMatrix2.SetRotate(gfRotation).pointee *
        gfMatrix3.SetTranslate(focus).pointee

      return cameraTransform
    }

    public func getRotation() -> Pixar.GfRotation
    {
      #if canImport(Gf)
      var gfRotation = Pixar.GfRotation(Pixar.GfVec3d.ZAxis(), rotation[2])
      gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.XAxis(), rotation[0])
      gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.YAxis(), rotation[1])

      if isZUp
      {
        gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.XAxis(), 90.0)
      }

      return gfRotation
      #else
      var gfRotation = pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.ZAxis(), rotation[2]))
      gfRotation *= pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.XAxis(), rotation[0]))
      gfRotation *= pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.YAxis(), rotation[1]))

      if isZUp
      {
        gfRotation *= pxr.GfMatrix4d.MakeRotate(Pixar.GfRotation(Pixar.GfVec3d.XAxis(), 90.0))
      }

      return gfRotation.ExtractRotation()
      #endif
    }

    /// The camera's right and up directions in world space, used to pan the focus point within the screen plane.
    public func screenAxes() -> (right: Pixar.GfVec3d, up: Pixar.GfVec3d)
    {
      let transform = getTransform()
      let right = transform.TransformDir(Pixar.GfVec3d(1.0, 0.0, 0.0))
      let up = transform.TransformDir(Pixar.GfVec3d(0.0, 1.0, 0.0))
      return (right, up)
    }
  }
}
