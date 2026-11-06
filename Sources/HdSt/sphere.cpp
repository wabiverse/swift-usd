//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"

#include "HdSt/sphere.h"
#include "HdSt/drawItem.h"
#include "HdSt/resourceRegistry.h"
#include "HdSt/tokens.h"

#include "Hd/bufferSpec.h"
#include "Hd/perfLog.h"
#include "Hd/sceneIndexAdapterSceneDelegate.h"
#include "Hd/sphereSchema.h"
#include "Hd/vtBufferSource.h"

#include "Vt/value.h"

PXR_NAMESPACE_OPEN_SCOPE


HdStSphere::HdStSphere(SdfPath const &id)
  : HdStImplicitSurface(
        id,
        HdStNativeImplicitsTokens->sphere,
        HdBufferSpecVector{HdBufferSpec(HdStNativeImplicitsTokens->sphereRadius,
                                        HdTupleType{HdTypeFloat, 1})})
{
}

void
HdStSphere::_PopulateCustomConstantPrimvars(HdSceneDelegate *sceneDelegate,
                                            HdRenderParam *renderParam,
                                            HdStDrawItem *drawItem)
{
    HD_TRACE_FUNCTION();
    HF_MALLOC_TAG_FUNCTION();

    HdStResourceRegistrySharedPtr resourceRegistry =
        std::static_pointer_cast<HdStResourceRegistry>(
            sceneDelegate->GetRenderIndex().GetResourceRegistry());

    HdBufferArrayRangeSharedPtr const& bar = drawItem->GetConstantPrimvarRange();

    const float radius = static_cast<float>(sceneDelegate->Get(GetId(),
                            HdSphereSchemaTokens->radius).Get<double>());

    HdBufferSourceSharedPtrVector sources = {
        std::make_shared<HdVtBufferSource>(
            HdStNativeImplicitsTokens->sphereRadius, VtValue(radius))
    };

    resourceRegistry->AddSources(bar, std::move(sources));
}

PXR_NAMESPACE_CLOSE_SCOPE
