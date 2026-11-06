//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "Gf/duration.h"
#include "Tf/hash.h"
#include "Tf/pyResultConversions.h"
#include "Tf/stringUtils.h"

#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/class.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/def.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/implicit.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/operators.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

#include <sstream>

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

namespace {

static std::string _Str(GfDuration const &self)
{
    return TfStringify(self);
}

static std::string
_Repr(GfDuration const &self)
{
    std::ostringstream repr;
    repr << TF_PY_REPR_PREFIX << "Duration(" << self << ")";
    return repr.str();
}

static bool _HasNonZeroDuration(GfDuration const &self)
{
    return self != GfDuration(0.0);
}

static double _Float(GfDuration const &self)
{
    return double(self);
}

} // anonymous namespace

void wrapDuration()
{
    typedef GfDuration This;

    auto selfCls = class_<This>("Duration", init<>())
        .def(init<double>())

        .def("GetValue", &This::GetValue)

        .def("__repr__", _Repr)
        .def("__str__", _Str)
        .def("__bool__", _HasNonZeroDuration)
        .def("__hash__", &This::GetHash)
        .def("__float__", _Float)

        .def( self == self )
        .def( double() == self )
        .def( self != self )
        .def( double() != self )
        .def( self < self )
        .def( double() < self )
        .def( self > self )
        .def( double() > self )
        .def( self <= self )
        .def( double() <= self )
        .def( self >= self )
        .def( double() >= self )

        .def( self * double() )
        .def( double() * self )
        .def( self / double() )
        .def( self / self )
        .def( self + self )
        .def( self + double() )
        .def( double() + self )
        .def( self - self )
        .def( double() - self )
        .def( -self )
        ;

    implicitly_convertible<double, This>();
}
