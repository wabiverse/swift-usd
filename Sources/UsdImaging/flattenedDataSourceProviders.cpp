//
// Copyright 2023 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "UsdImaging/flattenedDataSourceProviders.h"

#include "UsdImaging/flattenedGeomModelDataSourceProvider.h"
#include "UsdImaging/flattenedMaterialBindingsDataSourceProvider.h"
#include "UsdImaging/geomModelSchema.h"
#include "UsdImaging/materialBindingsSchema.h"
#include "UsdImaging/modelSchema.h"
#include "UsdImaging/sceneIndexPlugin.h"
#include "UsdImaging/usdUpAxisSchema.h"

#include "Hd/flattenedDataSourceProviders.h"
#include "Hd/flattenedOverlayDataSourceProvider.h"
#include "Hd/overlayContainerDataSource.h"
#include "Hd/retainedDataSource.h"

#include "Trace/traceImpl.h"

PXR_NAMESPACE_OPEN_SCOPE

static
HdContainerDataSourceHandle
_UsdFlattenedDataSourceProviders()
{
    using namespace HdMakeDataSourceContainingFlattenedDataSourceProvider;

    return
        HdRetainedContainerDataSource::New(
            UsdImagingMaterialBindingsSchema::GetSchemaToken(),
            Make<UsdImagingFlattenedMaterialBindingsDataSourceProvider>(),

            UsdImagingGeomModelSchema::GetSchemaToken(),
            Make<UsdImagingFlattenedGeomModelDataSourceProvider>(),

            UsdImagingModelSchema::GetSchemaToken(),
            Make<HdFlattenedOverlayDataSourceProvider>(),

            UsdImagingUsdUpAxisSchema::GetSchemaToken(),
            Make<HdFlattenedOverlayDataSourceProvider>());
}

static
HdContainerDataSourceHandle
_FlattenedDataSourceProviders()
{
    TRACE_FUNCTION();
    
    std::vector<HdContainerDataSourceHandle> result;

    // Usd-specific flattening
    result.push_back(_UsdFlattenedDataSourceProviders());

    // Flattening from UsdImaging scene index plugins.
    for (const UsdImagingSceneIndexPluginUniquePtr &sceneIndexPlugin :
             UsdImagingSceneIndexPlugin::GetAllSceneIndexPlugins()) {
        if (HdContainerDataSourceHandle ds =
                sceneIndexPlugin->FlattenedDataSourceProviders()) {
            result.push_back(std::move(ds));
        }
    }

    // Basic flattening from Hydra.
    result.push_back(HdFlattenedDataSourceProviders());

    return HdOverlayContainerDataSource::New(result.size(), result.data());
}


HdContainerDataSourceHandle
UsdImagingFlattenedDataSourceProviders()
{
    static HdContainerDataSourceHandle const result =
        _FlattenedDataSourceProviders();
    return result;
}

PXR_NAMESPACE_CLOSE_SCOPE
