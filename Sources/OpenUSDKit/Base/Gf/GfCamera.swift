/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#if canImport(Gf)
  import Gf
#else
  import OpenUSD
#endif

/**
 * # GfCamera
 *
 * Object-based representation of a camera.
 *
 * This class provides a thin wrapper on the
 * camera data model, with a small number of
 * computations. */
public typealias GfCamera = Pixar.GfCamera

public extension Gf
{
  /**
   * # GfCamera
   *
   * Object-based representation of a camera.
   *
   * This class provides a thin wrapper on the
   * camera data model, with a small number of
   * computations. */
  typealias Camera = GfCamera
}

public extension Gf.Camera
{
  /// Creates a camera with the given viewing parameters.
  init(transform: Gf.Matrix4d = Gf.Matrix4d(1.0),
       projection: Projection = .init(0),
       horizontalAperture: Float = Float(Pixar.GfCamera.DEFAULT_HORIZONTAL_APERTURE),
       verticalAperture: Float = Float(Pixar.GfCamera.DEFAULT_VERTICAL_APERTURE),
       horizontalApertureOffset: Float = 0.0,
       verticalApertureOffset: Float = 0.0,
       focalLength: Float = 50.0,
       clippingRange: Pixar.GfRange1f = Pixar.GfRange1f(1, 1_000_000),
       clippingPlanes: [Pixar.GfVec4f] = [],
       fStop: Float = 0.0,
       focusDistance: Float = 0.0)
  {
    self = Gf.Camera(
      transform,
      projection,
      horizontalAperture,
      verticalAperture,
      horizontalApertureOffset,
      verticalApertureOffset,
      focalLength,
      clippingRange,
      clippingPlanes.reduce(into: .init()) { $0.push_back($1) },
      fStop,
      focusDistance
    )
  }

  /// The transform of the filmback in world space.
  var transform: Gf.Matrix4d
  {
    get { GetTransform() }
    set { SetTransform(newValue) }
  }

  /// The projection type.
  var projection: Projection
  {
    get { GetProjection() }
    set { SetProjection(newValue) }
  }

  /// The focal length, in tenths of a world unit
  /// (e.g. mm if the world unit is assumed to be cm).
  var focalLength: Float
  {
    get { GetFocalLength() }
    set { SetFocalLength(newValue) }
  }

  /// The width of the projector aperture, in tenths of a world unit
  /// (e.g. mm if the world unit is assumed to be cm).
  var horizontalAperture: Float
  {
    get { GetHorizontalAperture() }
    set { SetHorizontalAperture(newValue) }
  }

  /// The height of the projector aperture, in tenths of a world unit
  /// (e.g. mm if the world unit is assumed to be cm).
  var verticalAperture: Float
  {
    get { GetVerticalAperture() }
    set { SetVerticalAperture(newValue) }
  }

  /// The horizontal offset of the projector aperture, in tenths of a
  /// world unit (e.g. mm if the world unit is assumed to be cm). Needed
  /// when writing out a stereo camera with finite convergence distance
  /// as two cameras.
  var horizontalApertureOffset: Float
  {
    get { GetHorizontalApertureOffset() }
    set { SetHorizontalApertureOffset(newValue) }
  }

  /// The vertical offset of the projector aperture, in tenths of a
  /// world unit (e.g. mm if the world unit is assumed to be cm).
  var verticalApertureOffset: Float
  {
    get { GetVerticalApertureOffset() }
    set { SetVerticalApertureOffset(newValue) }
  }

  /// The projector aperture aspect ratio.
  var aspectRatio: Float
  {
    GetAspectRatio()
  }

  /// Sets the frustum to be projective with the given `aspectRatio` and
  /// horizontal, respectively vertical, field of view `fieldOfView`
  /// (similar to `gluPerspective` when `direction` is `.FOVVertical`).
  /// Pass `horizontalAperture` only if depth of field matters.
  mutating func setPerspectiveFromAspectRatioAndFieldOfView(
    aspectRatio: Float,
    fieldOfView: Float,
    direction: FOVDirection,
    horizontalAperture: Float = Float(Pixar.GfCamera.DEFAULT_HORIZONTAL_APERTURE))
  {
    SetPerspectiveFromAspectRatioAndFieldOfView(aspectRatio, fieldOfView, direction, horizontalAperture)
  }

  /// Sets the frustum to be orthographic with the given `aspectRatio`, such that
  /// the orthographic width (or height, depending on `direction`), in cm, equals
  /// `orthographicSize`.
  mutating func setOrthographicFromAspectRatioAndSize(
    aspectRatio: Float,
    orthographicSize: Float,
    direction: FOVDirection)
  {
    SetOrthographicFromAspectRatioAndSize(aspectRatio, orthographicSize, direction)
  }

  /// Sets the camera from a view and projection matrix. The projection matrix
  /// only determines the ratio of aperture to focal length, so `focalLength`
  /// picks which of that ratio's equivalent values to store.
  mutating func setFromViewAndProjectionMatrix(
    view viewMatrix: Gf.Matrix4d,
    projection projMatrix: Gf.Matrix4d,
    focalLength: Float = 50.0)
  {
    SetFromViewAndProjectionMatrix(viewMatrix, projMatrix, focalLength)
  }

  /// Returns the horizontal or vertical field of view, in degrees.
  func getFieldOfView(_ direction: FOVDirection) -> Float
  {
    GetFieldOfView(direction)
  }

  /// The clipping range, in world units.
  var clippingRange: Pixar.GfRange1f
  {
    get { GetClippingRange() }
    set { SetClippingRange(newValue) }
  }

#if canImport(Gf)
  private borrowing func getClippingPlanesCopy() -> [Pixar.GfVec4f]
  {
    Array(__GetClippingPlanesUnsafe().pointee)
  }
#endif

  /// Additional, arbitrarily-oriented clip planes. A plane `(a, b, c, d)`
  /// clips off points `(x, y, z)`, in the camera's own space, where
  /// `a*x + b*y + c*z + d < 0`.
  var clippingPlanes: [Pixar.GfVec4f]
  {
    get
    {
      #if canImport(Gf)
        getClippingPlanesCopy()
      #else
        Array(GetClippingPlanes())
      #endif
    }
    set
    {
      SetClippingPlanes(newValue.reduce(into: .init()) { $0.push_back($1) })
    }
  }

  /// The lens aperture, unitless. 0 disables depth of field.
  var fStop: Float
  {
    get { GetFStop() }
    set { SetFStop(newValue) }
  }

  /// The focus distance, in world units.
  var focusDistance: Float
  {
    get { GetFocusDistance() }
    set { SetFocusDistance(newValue) }
  }

  /// The computed, world-space camera frustum.
  /// Always that of a Y-up, -Z-looking camera.
  var frustum: Gf.Frustum
  {
    GetFrustum()
  }
}
