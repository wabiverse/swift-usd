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

#include "USDOverlays/VtArrayOverlay.h"

namespace Overlay
{
  const bool *cdata(const Pixar::VtBoolArray &array)
  {
    return array.cdata();
  }

  const int *cdata(const Pixar::VtIntArray &array)
  {
    return array.cdata();
  }

  const unsigned int *cdata(const Pixar::VtUIntArray &array)
  {
    return array.cdata();
  }

  const int64_t *cdata(const Pixar::VtInt64Array &array)
  {
    return array.cdata();
  }

  const uint64_t *cdata(const Pixar::VtUInt64Array &array)
  {
    return array.cdata();
  }

  const float *cdata(const Pixar::VtFloatArray &array)
  {
    return array.cdata();
  }

  const double *cdata(const Pixar::VtDoubleArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec2f *cdata(const Pixar::VtVec2fArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec3f *cdata(const Pixar::VtVec3fArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec4f *cdata(const Pixar::VtVec4fArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec2d *cdata(const Pixar::VtVec2dArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec3d *cdata(const Pixar::VtVec3dArray &array)
  {
    return array.cdata();
  }

  const Pixar::GfVec4d *cdata(const Pixar::VtVec4dArray &array)
  {
    return array.cdata();
  }

  Pixar::VtBoolArray vtArray(const bool *src, size_t count)
  {
    return count ? Pixar::VtBoolArray(src, src + count) : Pixar::VtBoolArray();
  }

  Pixar::VtIntArray vtArray(const int *src, size_t count)
  {
    return count ? Pixar::VtIntArray(src, src + count) : Pixar::VtIntArray();
  }

  Pixar::VtUIntArray vtArray(const unsigned int *src, size_t count)
  {
    return count ? Pixar::VtUIntArray(src, src + count) : Pixar::VtUIntArray();
  }

  Pixar::VtInt64Array vtArray(const int64_t *src, size_t count)
  {
    return count ? Pixar::VtInt64Array(src, src + count) : Pixar::VtInt64Array();
  }

  Pixar::VtUInt64Array vtArray(const uint64_t *src, size_t count)
  {
    return count ? Pixar::VtUInt64Array(src, src + count) : Pixar::VtUInt64Array();
  }

  Pixar::VtFloatArray vtArray(const float *src, size_t count)
  {
    return count ? Pixar::VtFloatArray(src, src + count) : Pixar::VtFloatArray();
  }

  Pixar::VtDoubleArray vtArray(const double *src, size_t count)
  {
    return count ? Pixar::VtDoubleArray(src, src + count) : Pixar::VtDoubleArray();
  }

  Pixar::VtVec2fArray vtArray(const Pixar::GfVec2f *src, size_t count)
  {
    return count ? Pixar::VtVec2fArray(src, src + count) : Pixar::VtVec2fArray();
  }

  Pixar::VtVec3fArray vtArray(const Pixar::GfVec3f *src, size_t count)
  {
    return count ? Pixar::VtVec3fArray(src, src + count) : Pixar::VtVec3fArray();
  }

  Pixar::VtVec4fArray vtArray(const Pixar::GfVec4f *src, size_t count)
  {
    return count ? Pixar::VtVec4fArray(src, src + count) : Pixar::VtVec4fArray();
  }

  Pixar::VtVec2dArray vtArray(const Pixar::GfVec2d *src, size_t count)
  {
    return count ? Pixar::VtVec2dArray(src, src + count) : Pixar::VtVec2dArray();
  }

  Pixar::VtVec3dArray vtArray(const Pixar::GfVec3d *src, size_t count)
  {
    return count ? Pixar::VtVec3dArray(src, src + count) : Pixar::VtVec3dArray();
  }

  Pixar::VtVec4dArray vtArray(const Pixar::GfVec4d *src, size_t count)
  {
    return count ? Pixar::VtVec4dArray(src, src + count) : Pixar::VtVec4dArray();
  }
}  // namespace Overlay
