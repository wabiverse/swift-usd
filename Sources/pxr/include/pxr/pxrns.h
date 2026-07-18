/* ----------------------------------------------------------------
 * :: :  M  E  T  A  V  E  R  S  E  :                            ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                                        Copyright (C) 2016 Pixar.
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */
#ifndef __PXRNS_H__
#define __PXRNS_H__

/// \file pxr/pxr.h

#define PXR_MAJOR_VERSION 0
#define PXR_MINOR_VERSION 26
#define PXR_PATCH_VERSION 8

#define PXR_VERSION 2608

#define PXR_USE_NAMESPACES 1

#if PXR_USE_NAMESPACES

#  define PXR_NS pxr
#  define PXR_NS_GLOBAL ::PXR_NS

/* ------ swift usd. ------ */

#  define SWIFTUSD_EVOLUTION 2
#  define PXR_INTERNAL_NS Pixar

/* ------------------------ */

// A doc for the purposes of root level namespace documentation in Swift.
// NOTE: PXR_INTERNAL_NS has been unwrapped to Pixar on L.45 to help the
// linter out.

/**
  # ``Pixar``

  ## Overview

  The **Pixar** namespace is the top level namespace for all **USD** modules.
  While you *can* use the **Pixar** namespace directly, it is recommended that you
  use the **Pixar** namespace as a **container** for these other Pixar modules, such
  as **Pixar.Tf** and **Pixar.Gf**, as these inner Pixar modules contain the swift
  wrappers for the c++ classes and functions, providing a more **swifty** interface
  to the underlying c++ code, which is far safer and more convenient to use than the
  c++ code directly.

  - **Notice**: This is analogous to the **pxr** namespace in c++. In swift, an enum
  cannot "use" another enum to globally inject it into it's scope, so the longer form
  of the internal namespace `pxrInternal_v0_23__pxrReserved__` becomes the **pxr**
  namespace. Due to a Swift compiler bug when attempting to create a typealias to a
  c++ namespace (swift enum), Wabi renamed this namespace to **Pixar** for developer
  convenience, else users would have to use the longer form of the namespace in swift
  code.
 */
namespace Pixar {
}

// The root level namespace for all source in the USD distribution.
namespace PXR_NS {
using namespace PXR_INTERNAL_NS;
}

#  define PXR_NAMESPACE_OPEN_SCOPE namespace PXR_INTERNAL_NS {
#  define PXR_NAMESPACE_CLOSE_SCOPE }
#  define PXR_NAMESPACE_USING_DIRECTIVE using namespace PXR_NS;

#else

#  define PXR_NS
#  define PXR_NS_GLOBAL
#  define PXR_NAMESPACE_OPEN_SCOPE
#  define PXR_NAMESPACE_CLOSE_SCOPE
#  define PXR_NAMESPACE_USING_DIRECTIVE

#endif  // PXR_USE_NAMESPACES

#define PXR_PYTHON_SUPPORT_ENABLED 0

#if 1
#  define PXR_PREFER_SAFETY_OVER_SPEED 1
#endif

#endif  // __PXRNS_H__
