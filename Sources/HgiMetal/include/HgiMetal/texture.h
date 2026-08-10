//
// Copyright 2020 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_IMAGING_HGI_METAL_TEXTURE_H
#define PXR_IMAGING_HGI_METAL_TEXTURE_H

#include <Metal/Metal.h>

#include "pxr/pxrns.h"
#include "HgiMetal/api.h"
#include "Hgi/texture.h"
#include "Arch/swiftInterop.h"


PXR_NAMESPACE_OPEN_SCOPE

class HgiMetal;

/// \class HgiMetalTexture
///
/// Represents a Metal GPU texture resource.
///
class SWIFT_UNSAFE_REFERENCE HgiMetalTexture final : public HgiTexture {
public:
    HGIMETAL_API
    ~HgiMetalTexture() override;

    HGIMETAL_API
    size_t GetByteSizeOfResource() const override;

    /// This hgi transition helper returns the Metal resource as uint64_t
    /// for external clients.
    HGIMETAL_API
    uint64_t GetRawResource() const override;

    /// Returns the handle to the Metal texture.
    HGIMETAL_API
    id<MTLTexture> GetTextureId() const;
    
    /// This function does not do anything. At the moment there is no need for 
    /// explicit layout transitions for the Metal backend. Hence this function 
    /// simply returns 0 (none).
    HGIMETAL_API
    HgiTextureUsage SubmitLayoutChange(HgiTextureUsage newLayout) override;

protected:
    friend class HgiMetal;

    HGIMETAL_API
    HgiMetalTexture(HgiMetal *hgi,
                    HgiTextureDesc const & desc,
                    uint64_t rawResource = 0);
    
    HGIMETAL_API
    HgiMetalTexture(HgiMetal *hgi,
                    HgiTextureViewDesc const & desc);
    
private:
    HgiMetalTexture() = delete;
    HgiMetalTexture & operator=(const HgiMetalTexture&) = delete;
    HgiMetalTexture(const HgiMetalTexture&) = delete;

    id<MTLTexture> _textureId;
};


PXR_NAMESPACE_CLOSE_SCOPE

#endif
