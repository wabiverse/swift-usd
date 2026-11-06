//
// Copyright 2025 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include <UsdVolImaging/dataSourceParticleField.h>

#include "UsdImaging/dataSourceAttribute.h"
#include "UsdImaging/dataSourcePrimvars.h"

#include "UsdVol/particleField3DGaussianSplat.h"

#include "Hd/retainedDataSource.h"
#include "Hd/overlayContainerDataSource.h"
#include "Hd/particleFieldSchema.h"
#include "Hd/primvarsSchema.h"
#include "Hd/tokens.h"

PXR_NAMESPACE_OPEN_SCOPE

UsdImagingDataSourceParticleFieldPrim::UsdImagingDataSourceParticleFieldPrim(
    const SdfPath& sceneIndexPath, UsdPrim usdPrim,
    const UsdImagingDataSourceStageGlobals& stageGlobals)
    : UsdImagingDataSourceGprim(sceneIndexPath, usdPrim, stageGlobals) {}

static const UsdImagingDataSourceCustomPrimvars::Mappings
_GetCustomPrimvarMappings(const UsdPrim& usdPrim) {
    UsdImagingDataSourceCustomPrimvars::Mappings mappings = {
        {
            UsdVolTokens->radianceSphericalHarmonicsDegree,
            UsdVolTokens->radianceSphericalHarmonicsDegree,
            HdPrimvarSchemaTokens->constant
        }
    };

    // XXX: Todo: instead of creating the GS prim here, check for application
    // of FooAttributeAPI, to make this code reusable for other concrete
    // particle field instantiations.
    UsdVolParticleField3DGaussianSplat gs(usdPrim);
    TfToken usdName;

    gs.UsesFloatPositions(&usdName);
    mappings.push_back(
        {
            UsdVolTokens->positions,
            usdName,
            HdPrimvarSchemaTokens->vertex
        });
    gs.UsesFloatOrientations(&usdName);
    mappings.push_back(
        {
            UsdVolTokens->orientations,
            usdName,
            HdPrimvarSchemaTokens->vertex
        });
    gs.UsesFloatScales(&usdName);
    mappings.push_back(
        {
            UsdVolTokens->scales,
            usdName,
            HdPrimvarSchemaTokens->vertex
        });
    gs.UsesFloatOpacities(&usdName);
    mappings.push_back(
        {
            UsdVolTokens->opacities,
            usdName,
            HdPrimvarSchemaTokens->vertex
        });
    gs.UsesFloatRadianceCoefficients(&usdName);
    mappings.push_back(
        {
            UsdVolTokens->radianceSphericalHarmonicsCoefficients,
            usdName,
            HdPrimvarSchemaTokens->vertex
        });

    return mappings;
}

TfTokenVector
UsdImagingDataSourceParticleFieldPrim::GetNames() {
    TfTokenVector names = UsdImagingDataSourceGprim::GetNames();
    if (std::find(names.begin(), names.end(),
            HdParticleFieldSchema::GetSchemaToken()) == names.end()) {
        names.push_back(HdParticleFieldSchema::GetSchemaToken());
    }
    return names;
}

HdDataSourceBaseHandle
UsdImagingDataSourceParticleFieldPrim::Get(const TfToken& name) {

    if (name == HdParticleFieldSchema::GetSchemaToken()) {

        UsdVolParticleField3DGaussianSplat gs(_GetUsdPrim());

        // XXX: right now, we hardcode the kernel type as "gaussian ellipsoid",
        // since we don't have any other concrete particleField types.
        // Eventually, we should determine this value through API type
        // reflection.
        return HdRetainedContainerDataSource::New(
            HdParticleFieldSchemaTokens->kernelType,
            HdRetainedTypedSampledDataSource<TfToken>::New(
                TfToken("gaussianEllipsoid")),
            UsdVolTokens->projectionModeHint,
            UsdImagingDataSourceAttributeNew(
                gs.GetProjectionModeHintAttr(),
                _GetStageGlobals(),
                _GetSceneIndexPath(),
                HdParticleFieldSchema::GetDefaultLocator()),
            UsdVolTokens->sortingModeHint,
            UsdImagingDataSourceAttributeNew(
                gs.GetSortingModeHintAttr(),
                _GetStageGlobals(),
                _GetSceneIndexPath(),
                HdParticleFieldSchema::GetDefaultLocator()));
    }

    HdDataSourceBaseHandle const result = UsdImagingDataSourceGprim::Get(name);

    if (name == HdPrimvarsSchema::GetSchemaToken()) {
        return HdOverlayContainerDataSource::New(
            HdContainerDataSource::Cast(result),
            UsdImagingDataSourceCustomPrimvars::New(
                _GetSceneIndexPath(), _GetUsdPrim(),
                _GetCustomPrimvarMappings(_GetUsdPrim()), _GetStageGlobals()));
    }

    return result;
}

/*static*/
HdDataSourceLocatorSet
UsdImagingDataSourceParticleFieldPrim::Invalidate(
    UsdPrim const& prim, const TfToken& subprim,
    const TfTokenVector& properties,
    const UsdImagingPropertyInvalidationType invalidationType) {
    HdDataSourceLocatorSet result =
        UsdImagingDataSourceGprim::Invalidate(
            prim, subprim, properties, invalidationType);

    if (subprim.IsEmpty()) {
        // Unfortunately can't use CustomPrimvars::Invalidate here, since we
        // need to check for both float/half names.
        for (const TfToken &propertyName : properties) {
            if (propertyName == UsdVolTokens->positions ||
                propertyName == UsdVolTokens->positionsh) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->positions));
            }
            if (propertyName == UsdVolTokens->orientations ||
                propertyName == UsdVolTokens->orientationsh) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->orientations));
            }
            if (propertyName == UsdVolTokens->scales ||
                propertyName == UsdVolTokens->scalesh) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->scales));
            }
            if (propertyName == UsdVolTokens->opacities ||
                propertyName == UsdVolTokens->opacitiesh) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->opacities));
            }
            if (propertyName == UsdVolTokens->radianceSphericalHarmonicsCoefficients ||
                propertyName == UsdVolTokens->radianceSphericalHarmonicsCoefficientsh) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->radianceSphericalHarmonicsCoefficients));
            }
            if (propertyName == UsdVolTokens->radianceSphericalHarmonicsDegree) {
                result.insert(HdPrimvarsSchema::GetDefaultLocator().Append(
                    UsdVolTokens->radianceSphericalHarmonicsDegree));
            }
            // 3D Gaussian Splat hints
            if (propertyName == UsdVolTokens->projectionModeHint ||
                propertyName == UsdVolTokens->sortingModeHint) {
                result.insert(HdParticleFieldSchema::GetDefaultLocator());
            }
            // Note that the kernel type is type-based, and so any change will
            // come as a prim resync, and we don't need to handle it here.
        }
    }

    return result;
}

PXR_NAMESPACE_CLOSE_SCOPE
