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

#ifndef SWIFTUSD_SWIFTOVERLAY_VTARRAY_OVERLAY_H
#define SWIFTUSD_SWIFTOVERLAY_VTARRAY_OVERLAY_H

#include "pxr/pxrns.h"

#include "Vt/types.h"
#include "Vt/array.h"

#include <cstdint>

/// Read-only buffer access for the `VtArray` value types, since ClangImporter
/// does not surface `VtArray<T>::cdata()` on the imported specializations.
///
/// Two independent guarantees matter to callers:
///
/// - **No hidden copy.** These wrap `cdata()`, the *const* accessor, which
///   never detaches the array's shared copy-on-write storage. (The non-const
///   `data()` detaches: if the buffer is shared, it silently deep-copies the
///   whole payload first - exactly the copy a zero-copy caller is avoiding.)
///
/// - **Lifetime.** The pointer targets the array's shared storage, which is
///   refcounted: it stays valid as long as any `VtArray` handle to it exists,
///   not just the one passed in. Keep such a handle alive for as long as the
///   pointer is in use.
///
/// The returned pointer is null for empty arrays.
namespace Overlay
{
  const bool *cdata(const Pixar::VtBoolArray &array);
  const int *cdata(const Pixar::VtIntArray &array);
  const unsigned int *cdata(const Pixar::VtUIntArray &array);
  const int64_t *cdata(const Pixar::VtInt64Array &array);
  const uint64_t *cdata(const Pixar::VtUInt64Array &array);
  const float *cdata(const Pixar::VtFloatArray &array);
  const double *cdata(const Pixar::VtDoubleArray &array);
  const Pixar::GfVec2f *cdata(const Pixar::VtVec2fArray &array);
  const Pixar::GfVec3f *cdata(const Pixar::VtVec3fArray &array);
  const Pixar::GfVec4f *cdata(const Pixar::VtVec4fArray &array);
  const Pixar::GfVec2d *cdata(const Pixar::VtVec2dArray &array);
  const Pixar::GfVec3d *cdata(const Pixar::VtVec3dArray &array);
  const Pixar::GfVec4d *cdata(const Pixar::VtVec4dArray &array);
}  // namespace Overlay

#endif  // SWIFTUSD_SWIFTOVERLAY_VTARRAY_OVERLAY_H
