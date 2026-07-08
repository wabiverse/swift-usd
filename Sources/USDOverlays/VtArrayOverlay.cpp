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
}  // namespace Overlay
