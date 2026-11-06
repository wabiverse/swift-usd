//
// Copyright 2025 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "UsdValidation/fixer.h"
#include "UsdValidation/error.h"
#include "Usd/editTarget.h"

#include "Tf/pyContainerConversions.h"
#include "Tf/pyError.h"
#include "Tf/pyLock.h"
#include "Tf/pyObjWrapper.h"
#include "Tf/pyPtrHelpers.h"
#include "Tf/pyResultConversions.h"
#include "Tf/pyUtils.h"

#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/class.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/def.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/make_constructor.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/object.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

namespace
{

// ---------------------------------------------------------------------------
// Python callable → C++ fixer function wrappers
//
// The Python callable is stored in a TfPyObjWrapper and the GIL is acquired
// before invoking it.
//
// FixerImplFn and FixerCanApplyFn share the same signature
// (UsdValidationError, UsdEditTarget, UsdTimeCode) -> bool, so a single
// wrapper function handles both.

static std::function<bool(const UsdValidationError &,
                          const UsdEditTarget &,
                          const UsdTimeCode &)>
_WrapFixerFn(object pyFn)
{
    return [wrapper = TfPyObjWrapper(pyFn)](
        const UsdValidationError &error,
        const UsdEditTarget &editTarget,
        const UsdTimeCode &timeCode) -> bool {
        TfPyLock lock;
        try {
            object result = wrapper.Get()(
                object(error),
                object(editTarget),
                object(timeCode));
            return extract<bool>(result);
        }
        catch (error_already_set const &) {
            TfPyConvertPythonExceptionToTfErrors();
            PyErr_Clear();
            return false;
        }
    };
}

// Construct a UsdValidationFixer from Python arguments, wrapping the
// Python callables into C++ std::functions with GIL safety.
// Returns a heap-allocated pointer as required by make_constructor.
UsdValidationFixer *
_MakeValidationFixer(const TfToken &name,
                     const std::string &description,
                     object fixerImplFn,
                     object canApplyFn,
                     const TfTokenVector &keywords,
                     const TfToken &errorName)
{
    if (!PyCallable_Check(fixerImplFn.ptr()) ||
        !PyCallable_Check(canApplyFn.ptr())) {
        TfPyThrowTypeError("fixerImplFn and canApplyFn must be callable");
    }

    return new UsdValidationFixer(
        name, description,
        _WrapFixerFn(fixerImplFn),
        _WrapFixerFn(canApplyFn),
        keywords, errorName);
}

} // anonymous namespace

void wrapUsdValidationFixer()
{
    class_<UsdValidationFixer>("ValidationFixer", no_init)
        .def("__init__",
             make_constructor(
                 &_MakeValidationFixer,
                 default_call_policies(),
                 (arg("name"), arg("description"),
                  arg("fixerImplFn"), arg("canApplyFn"),
                  arg("keywords") = TfTokenVector(),
                  arg("errorName") = TfToken())))
        .add_property("name",
            make_function(
                +[](const UsdValidationFixer &fixer) { 
                      return fixer.GetName(); 
                },
                return_value_policy<return_by_value>()))
        .add_property("description",
            make_function(
                +[](const UsdValidationFixer &fixer) { 
                    return fixer.GetDescription(); 
                },
                return_value_policy<return_by_value>()))
        .add_property("errorName",
            make_function(
                +[](const UsdValidationFixer &fixer) { 
                    return fixer.GetErrorName(); 
                },
                return_value_policy<return_by_value>()))
        .add_property("keywords",
            make_function(
                +[](const UsdValidationFixer &fixer) { 
                    return fixer.GetKeywords(); 
                },
                return_value_policy<TfPySequenceToList>()))
        .def("IsAssociatedWithErrorName", 
             &UsdValidationFixer::IsAssociatedWithErrorName, (arg("errorName")))
        .def("HasKeyword", 
             &UsdValidationFixer::HasKeyword, (arg("keyword")))
        .def("CanApplyFix", 
             &UsdValidationFixer::CanApplyFix,
             (arg("error"), arg("editTarget"), 
              arg("timeCode") = UsdTimeCode::Default()))
        .def("ApplyFix", 
             &UsdValidationFixer::ApplyFix,
             (arg("error"), arg("editTarget"), 
              arg("timeCode") = UsdTimeCode::Default()));

    TfPyRegisterStlSequencesFromPython<UsdValidationFixer>();
    TfPyRegisterStlSequencesFromPython<const UsdValidationFixer*>();
}
