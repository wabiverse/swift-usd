//
// Copyright 2026 Apple
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//

#include <UsdPmc/usdPmcEncoder.h>

#include "pxr/pxrns.h"
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/class.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/init.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

namespace {

static bool
_EncodeStage(UsdPmcMeshEncoder& self,
             const std::string& inFile,
             const std::string& outFile,
             const VtDictionary& options)
{
    return self.EncodeStage(inFile, outFile, options);
}

} // anonymous namespace

void wrapUsdPmcMeshEncoder()
{
    class_<UsdPmcMeshEncoder>("UsdPmcMeshEncoder", init<>())
        .def("EncodeStage", &_EncodeStage,
             (arg("inFile"), arg("outFile"), arg("options") = VtDictionary()))
        ;
}
