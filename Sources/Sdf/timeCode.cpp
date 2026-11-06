//
// Copyright 2019 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "Sdf/timeCode.h"
#include "Sdf/layerOffset.h"

#include "Tf/registryManager.h"
#include "Vt/array.h"
#include "Vt/arrayEdit.h"
#include "Vt/value.h"
#include "Vt/valueTransform.h"

PXR_NAMESPACE_OPEN_SCOPE

TF_REGISTRY_FUNCTION(VtValue)
{
    VtRegisterTransform(
        +[](GfTimeCode const &timeCode, SdfLayerOffset const &offset) {
            return offset * timeCode;
        });

    VtRegisterTransform(
        +[](GfDuration const &duration, SdfLayerOffset const &offset) {
            return offset * duration;
        });
}

PXR_NAMESPACE_CLOSE_SCOPE
