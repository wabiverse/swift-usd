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
public typealias GfVec3d = pxrInternal_v0_26_5__pxrReserved__.GfVec3d
#endif

public extension Hydra
{
  class Camera
  {
    private let isZUp: Bool
    public var params = Params()

    public struct Params
    {
      public var rotation = Pixar.GfVec3d(0.0)
      public var focus = Pixar.GfVec3d(0.0)
      public var distance = 50.0
      public var focalLength = 0.0
      public var projection = Pixar.GfCamera.Projection(0)
      public var leftBottomNear = Pixar.GfVec3d()
      public var rightTopFar = Pixar.GfVec3d()
      public var scaleViewport = 1.0
    }

    public var position = Pixar.GfVec3d()
    public var standardFocalLength = Double()
    public var scaleBias = Double()

    public init(isZUp: Bool)
    {
      self.isZUp = isZUp
      params.rotation = Pixar.GfVec3d(0.0)
      params.focus = Pixar.GfVec3d(0.0)
      params.distance = 50.0
      params.scaleViewport = 1.0
    }

    public func getTransform() -> GfMatrix4d
    {
      let gfRotation = getRotation()
      var cameraTransform = GfMatrix4d(1.0)

      var gfMatrix1 = GfMatrix4d()
      var gfMatrix2 = GfMatrix4d()
      var gfMatrix3 = GfMatrix4d()

      cameraTransform =
        gfMatrix1.SetTranslate(Pixar.GfVec3d(0.0, 0.0, params.distance)).pointee *
        gfMatrix2.SetRotate(gfRotation).pointee *
        gfMatrix3.SetTranslate(params.focus).pointee

      return cameraTransform
    }

    public func getRotation() -> Pixar.GfRotation
    {
      #if canImport(Gf)
      var gfRotation = Pixar.GfRotation(Pixar.GfVec3d.ZAxis(), params.rotation[2])
      gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.XAxis(), params.rotation[0])
      gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.YAxis(), params.rotation[1])

      if isZUp
      {
        gfRotation *= Pixar.GfRotation(Pixar.GfVec3d.XAxis(), 90.0)
      }
      
      return gfRotation
      #else
      var gfRotation = pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.ZAxis(), params.rotation[2]))
      gfRotation *= pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.XAxis(), params.rotation[0]))
      gfRotation *= pxr.GfMatrix4d.MakeRotate(pxr.GfRotation(.YAxis(), params.rotation[1]))
      
      if isZUp
      {
        gfRotation *= pxr.GfMatrix4d.MakeRotate(Pixar.GfRotation(Pixar.GfVec3d.XAxis(), 90.0))
      }
      
      return gfRotation.ExtractRotation()
      #endif
    }

    public func getShaderParams() -> Params
    {
      return params
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
