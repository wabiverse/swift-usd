//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//

#include "Hd/sceneIndexPlugin.h"
#include "Hd/sceneIndexPluginRegistry.h"
#include "HdSi/renderPassPruneSceneIndex.h"
#include "UsdImaging/collectionPredicateLibrary.h"

PXR_NAMESPACE_OPEN_SCOPE

TF_DEFINE_PRIVATE_TOKENS(
    _tokens,
    ((sceneIndexPluginName, "UsdImaging_RenderPassPruneSceneIndexPlugin"))
);

// Plugin that implements pruning semantics based on the "prune" collection 
// authored on the active render pass. This plugin is registered for all
// renderers.
// Note: We could add this to the scene index graph created via
// UsdImagingCreateSceneIndices. Because the active render pass is set
// via the scene globals scene index (which is inserted after the scene assembly
// merging scene index) via the plugin system, we need to use the plugin system
// to order it after the scene globals scene index.
// 
class UsdImaging_RenderPassPruneSceneIndexPlugin : public HdSceneIndexPlugin
{
public:
    UsdImaging_RenderPassPruneSceneIndexPlugin() = default;

protected:
    HdSceneIndexBaseRefPtr _AppendSceneIndex(
        const HdSceneIndexBaseRefPtr &inputScene,
        const HdContainerDataSourceHandle &inputArgs) override {

        // Only support USD predicates when evaluating expressions on
        // render pass collections that use UsdCollectionAPI.
        // Hydra predicates are not supported because USD does not know of them.
        // 
        return HdsiRenderPassPruneSceneIndex::New(
            inputScene, UsdImagingGetCollectionPredicateLibrary());
    }
};

// -----------------------------------------------------------------------------
// The registration below is provided for backwards compatibility when the
// HdSceneIndexPluginRegistry's ordering policy is set to CppRegistrationOnly.
//
TF_REGISTRY_FUNCTION(TfType)
{
    HdSceneIndexPluginRegistry
        ::Define<UsdImaging_RenderPassPruneSceneIndexPlugin>();
}

TF_REGISTRY_FUNCTION(HdSceneIndexPlugin)
{
    // Run after the scene is assembled and scene globals are authored, but
    // before procedurals are expanded.
    // HdGpSceneIndexPlugin::GetInsertionPhase = 2.
    const HdSceneIndexPluginRegistry::InsertionPhase insertionPhase = 1;

    HdSceneIndexPluginRegistry::GetInstance().RegisterSceneIndexForRenderer(
        HdSceneIndexPluginRegistryTokens->allRenderers,
        _tokens->sceneIndexPluginName,
        nullptr, // No input args.
        insertionPhase,
        HdSceneIndexPluginRegistry::InsertionOrderAtStart);
}

PXR_NAMESPACE_CLOSE_SCOPE
