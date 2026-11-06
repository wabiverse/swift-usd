//
// Copyright 2017 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "HdStorm/rendererPlugin.h"

#include "HdSt/renderDelegate.h"
#include "Hd/renderDelegateInfo.h"
#include "Hd/rendererCreateArgsSchema.h"
#include "Hd/rendererPluginRegistry.h"
#include "Hd/renderSettingDescriptorSchema.h"
#include "Hd/retainedDataSource.h"
#include "Hd/sceneIndexCreateArgsSchema.h"
#include "Hd/schemaTypeDefs.h"


PXR_NAMESPACE_OPEN_SCOPE

TF_REGISTRY_FUNCTION(TfType)
{
    HdRendererPluginRegistry::Define<HdStormRendererPlugin>();
}

// Converts a list of render setting descriptors into a container data source
// mapping each descriptor's key to an HdRenderSettingDescriptorSchema.
static HdContainerDataSourceHandle
_ToContainerDataSource(const HdRenderSettingDescriptorList &descriptors)
{
    std::vector<TfToken> names;
    std::vector<HdDataSourceBaseHandle> values;
    names.reserve(descriptors.size());
    values.reserve(descriptors.size());
    for (const HdRenderSettingDescriptor &desc : descriptors) {
        names.push_back(desc.key);
        values.push_back(
            HdRenderSettingDescriptorSchema::Builder()
                .SetName(
                    HdRetainedTypedSampledDataSource<std::string>::New(
                        desc.name))
                .SetDefaultValue(
                    HdRetainedSampledDataSource::New(desc.defaultValue))
                .Build());
    }

    return HdRenderSettingDescriptorContainerSchema::BuildRetained(
        names.size(), names.data(), values.data());
}

HdRenderDelegate *
HdStormRendererPlugin::CreateRenderDelegate()
{
    return new HdStRenderDelegate();
}

HdRenderDelegate*
HdStormRendererPlugin::CreateRenderDelegate(
    HdRenderSettingsMap const& settingsMap)
{
    return new HdStRenderDelegate(settingsMap);
}

void
HdStormRendererPlugin::DeleteRenderDelegate(HdRenderDelegate *renderDelegate)
{
    delete renderDelegate;
}

bool
HdStormRendererPlugin::IsSupported(
    const HdRendererCreateArgsSchema &rendererCreateArgs,
    std::string * reasonWhyNot) const
{
    return HdStRenderDelegate::IsSupported(rendererCreateArgs, reasonWhyNot);
}

HdContainerDataSourceHandle
HdStormRendererPlugin::GetSceneIndexCreateArgs() const
{
    // The env-setting-derived defaults of the render settings are resolved at
    // call time, so we build this fresh per call rather than caching in a
    // static.
    return
        HdSceneIndexCreateArgsSchema::Builder()
            .SetMotionBlurSupport(
                HdRetainedTypedSampledDataSource<bool>::New(false))
            .SetCameraMotionBlurSupport(
                HdRetainedTypedSampledDataSource<bool>::New(true))
            .SetLegacyRenderDelegateInfo(
                HdRetainedTypedSampledDataSource<HdRenderDelegateInfo>::New(
                    HdStRenderDelegate::GetRenderDelegateInfo()))
            .SetRenderSettingDescriptors(
                _ToContainerDataSource(
                    HdStRenderDelegate::GetRenderSettingDescriptorsForPlugin()))
            .Build();
}

PXR_NAMESPACE_CLOSE_SCOPE
