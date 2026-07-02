//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//

#include "pxr/pxrns.h"
#include "UsdLod/heuristicQuery.h"

#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/class.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

void wrapHeuristicQuery()
{
    typedef UsdLodHeuristicQuery This;

    class_<This>("HeuristicQuery", no_init)

        .add_property(
            "lodDomain",
            +[](const This& self) { return self.lodDomain.GetString(); },
            +[](This& self,
                const std::string& value) { self.lodDomain = TfToken(value); })

        ;
}
