//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "UsdProfiles/profilesDocUtils.h"

#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/def.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/dict.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/extract.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/list.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/object.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/stl_iterator.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

#include <map>
#include <string>

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

namespace {

std::map<std::string, std::string>
_DictToMap(const dict& d)
{
    std::map<std::string, std::string> out;
    list keys = d.keys();
    const ssize_t n = len(keys);
    for (ssize_t i = 0; i < n; ++i) {
        object k = keys[i];
        object v = d[k];
        std::string ks = extract<std::string>(k);
        std::string vs = extract<std::string>(v);
        out.emplace(std::move(ks), std::move(vs));
    }
    return out;
}

std::string
_MarkdownNoArgs()
{
    return UsdProfilesMarkdown();
}

std::string
_MarkdownWithStyles(const dict& styles)
{
    return UsdProfilesMarkdown(_DictToMap(styles));
}

std::string
_Mermaid(const dict& styles)
{
    return UsdProfilesMermaid(_DictToMap(styles));
}

std::string
_Dot()
{
    return UsdProfilesDot();
}

} // anonymous namespace

void wrapUsdProfilesDocUtils()
{
    def("ProfilesMarkdown", &_MarkdownNoArgs);
    def("ProfilesMarkdown", &_MarkdownWithStyles, (arg("styles")));
    def("ProfilesMermaid",  &_Mermaid,            (arg("styles")));
    def("ProfilesDot",      &_Dot);
}
