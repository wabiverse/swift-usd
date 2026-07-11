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

#include "Gf/vec2f.h"
#include "Gf/vec3f.h"
#include "Gf/vec4f.h"
#include "Gf/vec2d.h"
#include "Gf/vec3d.h"
#include "Gf/vec4d.h"

#include "Vt/types.h"
#include "Vt/array.h"

#include <cstdint>

namespace Overlay
{
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
  template <typename ScalarType, class T>
  inline const ScalarType* cdata(const T &array) {
      return array.cdata();
  }

  /// Single-copy `VtArray` construction from a contiguous buffer - the
  /// write-side complement to `cdata`. `VtArray`'s range constructor is a
  /// member template, which ClangImporter does not instantiate, so without
  /// these the only construction path from Swift is per-element `push_back` -
  /// one cross-language call per element. Each of these performs one C++-side
  /// range copy instead. `src` may be null only when `count` is zero.
  template <class T, typename ScalarType>
  inline T vtArray(const ScalarType *src, std::size_t count) {
      return count ? T(src, src + count) : T();
  }
}  // namespace Overlay

#endif  // SWIFTUSD_SWIFTOVERLAY_VTARRAY_OVERLAY_H
