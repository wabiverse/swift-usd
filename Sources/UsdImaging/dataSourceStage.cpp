//
// Copyright 2022 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "UsdImaging/dataSourceStage.h"

#include "UsdImaging/usdUpAxisSchema.h"

#include "HdAr/systemSchema.h"

#include "Hd/retainedDataSource.h"
#include "Hd/sceneGlobalsSchema.h"
#include "Hd/systemSchema.h"

#include "Ar/resolverContext.h"
#include "Usd/stage.h"
#include "UsdGeom/metrics.h"
#include "UsdRender/tokens.h"

PXR_NAMESPACE_OPEN_SCOPE

TfTokenVector
UsdImagingDataSourceStage::GetNames()
{
    return {
        HdSystemSchema::GetSchemaToken(),
        HdSceneGlobalsSchema::GetSchemaToken(),
        HdSceneGlobalsSchema::GetSchemaToken(),
        UsdImagingUsdUpAxisSchema::GetSchemaToken(),
    };
}

HdDataSourceBaseHandle
UsdImagingDataSourceStage::Get(const TfToken& name)
{
    if (name == HdSystemSchema::GetSchemaToken()) {
        return HdRetainedContainerDataSource::New(
            HdarSystemSchemaTokens->assetResolution,
            HdarSystemSchema::Builder()
                .SetResolverContext(
                    HdRetainedTypedSampledDataSource<ArResolverContext>::New(
                        _stage->GetPathResolverContext()))
                .Build());
    }
    if (name == HdSceneGlobalsSchema::GetSchemaToken()) {
        // Update the sceneGlobals locator if we have stage metadata for the
        // the render settings prim to use for rendering.
        std::string pathStr;
        if (_stage->HasAuthoredMetadata(
                UsdRenderTokens->renderSettingsPrimPath)) {
            _stage->GetMetadata(
                UsdRenderTokens->renderSettingsPrimPath, &pathStr);
        }

        return HdSceneGlobalsSchema::Builder()
               .SetActiveRenderSettingsPrim(
                   pathStr.empty()
                       ? nullptr
                       : HdRetainedTypedSampledDataSource<SdfPath>::New(
                           SdfPath(pathStr)))
               .SetStartTimeCode(
                   HdRetainedTypedSampledDataSource<double>::New(
                       _stage->GetStartTimeCode()))
               .SetEndTimeCode(
                   HdRetainedTypedSampledDataSource<double>::New(
                       _stage->GetEndTimeCode()))
               .SetTimeCodesPerSecond(
                   HdRetainedTypedSampledDataSource<double>::New(
                       _stage->GetTimeCodesPerSecond()))
               .Build();
    }
    if (name == UsdImagingUsdUpAxisSchema::GetSchemaToken()) {
        return HdRetainedContainerDataSource::New(
                UsdImagingUsdUpAxisSchemaTokens->upAxis,
                HdRetainedTypedSampledDataSource<TfToken>::New(
                    UsdGeomGetStageUpAxis(_stage)));
    }
    return nullptr;
}

UsdImagingDataSourceStage::UsdImagingDataSourceStage(UsdStageRefPtr stage)
    : _stage(std::move(stage))
{
}

PXR_NAMESPACE_CLOSE_SCOPE
