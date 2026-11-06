//
// Copyright 2025 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"

#include "Sdf/variableExpression.h"
#include "Sdf/variableExpressionAST.h"

#include "Tf/pyResultConversions.h"

#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/bases.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/class.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/list.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/ptr.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/scope.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED
#if PXR_PYTHON_SUPPORT_ENABLED
#include "boost/python/return_internal_reference.hpp"
#endif // PXR_PYTHON_SUPPORT_ENABLED

PXR_NAMESPACE_USING_DIRECTIVE

using namespace pxr_boost::python;

class Sdf_VariableExpressionASTNodesNS
{
};

static void
wrapVariableExpressionASTNodes()
{
    using namespace SdfVariableExpressionASTNodes;

    scope s = class_<Sdf_VariableExpressionASTNodesNS>
        ("VariableExpressionASTNodes", no_init);

    {
        using This = Node;
        class_<This, noncopyable>("Node", no_init)
            .def("GetExpression", &This::GetExpression)
            ;
    }

    {
        using This = NodeList;
        class_<This, noncopyable>("NodeList", no_init)
            // XXX: Nodes in list need to have custodian_and_ward policy?
            .def("GetNodes", 
                +[](const This& l) {
                    list nodes;
                    for (const auto& n : l.GetNodes()) {
                        nodes.append(ptr(n));
                    }
                    return nodes;
                })

            .def("Append", &This::Append)
            .def("Set", &This::Set)
            .def("Insert", &This::Insert)
            .def("Remove", &This::Remove)
            .def("Clear", &This::Clear)
            ;
    }

    {
        using This = LiteralNode;
        auto c = class_<This, bases<Node>, noncopyable>
            ("LiteralNode", no_init)
            .def("GetValue", 
                +[](const This& n) {
                    return std::visit(
                        [](auto&& arg) { 
                            using T = std::decay_t<decltype(arg)>;
                            if constexpr (std::is_same_v<T, std::monostate>) {
                                return object();
                            }
                            else {
                                return object(arg);
                            }
                        }, 
                        n.GetValue());
                    })

            .def("SetValue",
                +[](This& n, const VtValue& v) {
                    if (v.IsEmpty()) {
                        n.SetValue({});
                    }
                    else if (v.IsHolding<bool>()) {
                        n.SetValue(v.UncheckedGet<bool>());
                    }
                    else if (v.CanCast<int64_t>()) {
                        // Depending on how big the numeric value is, v
                        // may be holding an int or a long. So we just cast
                        // to int64_t to handle both cases.
                        n.SetValue(VtValue::Cast<int64_t>(v)
                            .UncheckedGet<int64_t>());
                    }
                    else if (v.IsHolding<std::string>()) {
                        n.SetValue(v.UncheckedGet<std::string>());
                    }
                    else {
                        TfPyThrowValueError("Invalid value for node");
                    }
                })
            ;
    }

    {
        using This = VariableNode;
        class_<This, bases<Node>, noncopyable>
            ("VariableNode", no_init)
            .def("GetName", &This::GetName,
                return_value_policy<return_by_value>())
            .def("SetName", &This::SetName)
            .def("GetFallbackValue",
                +[](This& n) { return n.GetFallbackValue(); },
                return_internal_reference<>())
            .def("SetFallbackValue", &This::SetFallbackValue)
            .def("ClearFallbackValue", &This::ClearFallbackValue)
            ;
    }

    {
        using This = ListNode;
        class_<This, bases<Node>, noncopyable>
            ("ListNode", no_init)
            .def("GetElements",
                +[](This& n) -> NodeList& { return n.GetElements(); },
                return_internal_reference<>())
            ;
    }

    {
        using This = FunctionNode;
        class_<This, bases<Node>, noncopyable>
            ("FunctionNode", no_init)
            .def("GetName", &This::GetName,
                return_value_policy<return_by_value>())
            .def("SetName", &This::SetName)
            .def("GetArguments", 
                +[](This& fn) -> NodeList& { return fn.GetArguments(); },
                return_internal_reference<>())
            ;
    }
}

void
wrapVariableExpressionAST()
{
    wrapVariableExpressionASTNodes();

    using This = SdfVariableExpressionAST;
    class_<This, noncopyable>("VariableExpressionAST")
        .def(init<>())
        .def(init<const This&>()) // deep copy
        .def(init<const std::string&>(arg("expression")))
        .def(init<const SdfVariableExpression&>(arg("expression")))

        .def("__bool__", &This::operator bool)

        .def("GetErrors", &This::GetErrors,
            return_value_policy<TfPySequenceToList>())

        .def("GetRoot", +[](This& ast) { return ast.GetRoot(); },
            return_internal_reference<>())

        .def("GetExpression", &This::GetExpression)
        ;
}
