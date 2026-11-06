//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "Gf/timeCode.h"
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

static std::string _Str(GfTimeCode const &self)
{
    return TfStringify(self);
}

static std::string
_Repr(GfTimeCode const &self)
{
    std::ostringstream repr;
    repr << TF_PY_REPR_PREFIX << "TimeCode(" << self << ")";
    return repr.str();
}

static bool _HasNonZeroTimeCode(GfTimeCode const &self)
{
    return self != GfTimeCode(0.0);
}

static double _Float(GfTimeCode const &self)
{
    return double(self);
}

} // anonymous namespace

void wrapTimeCode()
{
    typedef GfTimeCode This;

    auto selfCls = class_<This>("TimeCode", init<>())
        .def(init<double>())

        .def("GetValue", &This::GetValue)

        .def("__repr__", _Repr)
        .def("__str__", _Str)
        .def("__bool__", _HasNonZeroTimeCode)
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

        .def( double() * self )
        .def( self * double() )

        .def( self / double() )
        .def( self / self )

        .def( self + self )
        .def( self + GfDuration() )
        .def( self + double() )
        .def( GfDuration() + self )
        .def( double() + self )

        .def( self - self )
        .def( self - GfDuration() )
        .def( GfDuration() - self )
        .def( double() - self )
        .def( self - double() )

        .def( -self )
        ;

    implicitly_convertible<double, This>();
}
