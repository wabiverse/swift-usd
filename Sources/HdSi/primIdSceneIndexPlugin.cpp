//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "HdSi/primIdSceneIndexPlugin.h"

#include "HdSi/primIdSceneIndex.h"
#include "Hd/sceneIndexPluginRegistry.h"

#include "Tf/envSetting.h"
#include "Tf/registryManager.h"
#include "Tf/staticTokens.h"
#include "Tf/type.h"

#include "pxr/pxrns.h"

PXR_NAMESPACE_OPEN_SCOPE

TF_DEFINE_ENV_SETTING(HDSI_ENABLE_PRIM_ID_SCENE_INDEX,
                      true,
                      "Append the HdsiPrimIdSceneIndex as one of the last "
                      "filtering scene indices for every renderer.");

TF_DEFINE_PRIVATE_TOKENS(
    _tokens,
    ((sceneIndexPluginName, "HdsiPrimIdSceneIndexPlugin")));

// Broad insertion phase chosen so the prim id scene index runs near the very
// end of the filtering graph, after the renderable prims have been finalized.
// The ordering is expressed in JSON metadata too (see plugInfo.json); the two
// are reconciled by the Hybrid plugin ordering policy.
static const HdSceneIndexPluginRegistry::InsertionPhase _insertionPhase = 1000;

TF_REGISTRY_FUNCTION(TfType)
{
    HdSceneIndexPluginRegistry::Define<HdsiPrimIdSceneIndexPlugin>();
}

TF_REGISTRY_FUNCTION(HdSceneIndexPlugin)
{
    HdSceneIndexPluginRegistry::GetInstance().RegisterSceneIndexForRenderer(
        HdSceneIndexPluginRegistryTokens->allRenderers,
        _tokens->sceneIndexPluginName,
        /* inputArgs = */ nullptr,
        _insertionPhase,
        HdSceneIndexPluginRegistry::InsertionOrderAtEnd);
}

HdsiPrimIdSceneIndexPlugin::
HdsiPrimIdSceneIndexPlugin() = default;

HdSceneIndexBaseRefPtr
HdsiPrimIdSceneIndexPlugin::_AppendSceneIndex(
    const HdSceneIndexBaseRefPtr &inputScene,
    const HdContainerDataSourceHandle &inputArgs)
{
    // This function shouldn't be called if the plugin isn't enabled.
    if (!TF_VERIFY(_IsEnabled(inputArgs))) {
        return inputScene;
    }

    return HdsiPrimIdSceneIndex::New(inputScene);
}

bool
HdsiPrimIdSceneIndexPlugin::_IsEnabled(
    const HdContainerDataSourceHandle& inputArgs) const
{
    return TfGetEnvSetting(HDSI_ENABLE_PRIM_ID_SCENE_INDEX);
}

PXR_NAMESPACE_CLOSE_SCOPE
