//
// Copyright 2016 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "UsdViewQ/utils.h"
#include "Plug/registry.h"
#include "Tf/staticTokens.h"

#include "Usd/attribute.h"
#include "Usd/attributeQuery.h"
#include "Usd/modelAPI.h"
#include "Usd/prim.h"
#include "Usd/schemaBase.h"
#include "Usd/stage.h"
#include "Usd/primRange.h"
#include "UsdGeom/camera.h"
#include "UsdGeom/imageable.h"
#include "UsdUI/objectHints.h"

PXR_NAMESPACE_OPEN_SCOPE

/*static*/
std::vector<UsdPrim> 
UsdviewqUtils::_GetAllPrimsOfType(UsdStagePtr const &stage, 
                                  TfType const& schemaType)
{
    std::vector<UsdPrim> result;
    UsdPrimRange range = stage->Traverse();
    std::copy_if(range.begin(), range.end(), std::back_inserter(result),
                 [schemaType](UsdPrim const &prim) {
                     return prim.IsA(schemaType);
                 });
    return result;
}

TF_DEFINE_PRIVATE_TOKENS(
    _tokens,
    (root)
);

UsdviewqUtils::PrimInfo::PrimInfo(const UsdPrim &prim, const UsdTimeCode time)
{
    hasCompositionArcs = (prim.HasAuthoredReferences() ||
                          prim.HasAuthoredPayloads() ||
                          prim.HasAuthoredInherits() ||
                          prim.HasAuthoredSpecializes() ||
                          prim.HasVariantSets());
    isActive = prim.IsActive();
    UsdGeomImageable img(prim);
    isImageable = static_cast<bool>(img);
    isDefined = prim.IsDefined();
    isAbstract = prim.IsAbstract();

    // isInPrototype is meant to guide UI to consider the prim's "source", so
    // even if the prim is a proxy prim, then unlike the core
    // UsdPrim.IsInPrototype(), we want to consider it as coming from a
    // prototype to make it visually distinctive.  If in future we need to
    // decouple the two concepts we can, but we're sensitive here to python
    // marshalling costs.
    isInPrototype = prim.IsInPrototype() || prim.IsInstanceProxy();


    // only show camera guides for now, until more guide generation logic is
    // moved into usdImaging
    supportsGuides = prim.IsA<UsdGeomCamera>();

    supportsDrawMode = isActive && isDefined && 
        !isInPrototype && prim.GetPath() != SdfPath::AbsoluteRootPath() &&
        UsdModelAPI(prim).IsModel();

    isInstance = prim.IsInstance();
    isVisibilityInherited = false;
    if (img){
        UsdAttributeQuery query(img.GetVisibilityAttr());
        TfToken visibility = UsdGeomTokens->inherited;
        query.Get(&visibility, time);
        isVisibilityInherited = (visibility == UsdGeomTokens->inherited);
        visVaries = query.ValueMightBeTimeVarying();
    }
    else {
        visVaries = false;
    }

    if (prim.GetParent())
        name = prim.GetName().GetString();
    else
        name = _tokens->root.GetString();
    typeName = prim.GetTypeName().GetString();

    displayName = UsdUIObjectHints(prim).GetDisplayName();
}

/*static*/
UsdviewqUtils::PrimInfo
UsdviewqUtils::GetPrimInfo(const UsdPrim &prim, const UsdTimeCode time)
{
    return PrimInfo(prim, time);
}

PXR_NAMESPACE_CLOSE_SCOPE

