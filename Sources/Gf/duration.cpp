//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "Gf/duration.h"
#include "Tf/registryManager.h"
#include "Tf/type.h"

#include <ostream>

PXR_NAMESPACE_OPEN_SCOPE

TF_REGISTRY_FUNCTION(TfType) {
    TfType::Define<GfDuration>();
}

std::ostream&
operator<<(std::ostream& out, const GfDuration& duration)
{
    return out << duration.GetValue();
}

PXR_NAMESPACE_CLOSE_SCOPE
