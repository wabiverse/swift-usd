//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"

#include "ExecIr/controllerBuilder.h"
#include "ExecIr/tokens.h"
#include "ExecIr/types.h"

#include "Exec/registerSchema.h"
#include "Vdf/context.h"

#include "Gf/matrix4d.h"
#include "Tf/token.h"

PXR_NAMESPACE_USING_DIRECTIVE

static ExecIrResult _Compute(const VdfContext &);
static ExecIrResult _Invert(const VdfContext &);

// TODO: This switch controller is hard coded to support two rigs, each of which
// controls two joint scopes. In the future, a general switch controller schema
// will be configurable via application of multi-apply schemas.
EXEC_REGISTER_COMPUTATIONS_FOR_SCHEMA(ExecIrSwitchController)
{
    ExecIrControllerBuilder builder(self, &_Compute, &_Invert);

    builder.SwitchAttribute<TfToken>(ExecIrTokens->switch_);

    builder.InvertibleInputAttributes<GfMatrix4d>({
        ExecIrTokens->rig1Space,
        ExecIrTokens->rig2Space,
    });

    builder.InvertibleOutputAttribute<GfMatrix4d>(ExecIrTokens->outSpace);
}

// The switch controller forward computation passes through the computed values
// for the rig that is currently selected, based on the value of the swtich
// avar.
//
static ExecIrResult
_Compute(const VdfContext &ctx)
{
    const TfToken &switchValue = ctx.GetInputValue<TfToken>(
        ExecIrTokens->switch_);
    if (switchValue == ExecIrTokens->rig1) {
        return {{
            {ExecIrTokens->outSpace,
             VtValue(ctx.GetInputValue<GfMatrix4d>(ExecIrTokens->rig1Space))},
        }};
    }
    else if (switchValue == ExecIrTokens->rig2) {
        return {{
            {ExecIrTokens->outSpace,
             VtValue(ctx.GetInputValue<GfMatrix4d>(ExecIrTokens->rig2Space))},
        }};
    } else {
        TF_VERIFY(false, "Unexpected switch value '%s'", switchValue.GetText());
        return {{}};
    }
}

// The switch controller inverse computation passes through the inverted values
// for the rig that is currently selected, based on the value of the swtich
// avar.
//
static ExecIrResult
_Invert(const VdfContext &ctx)
{
    const TfToken &switchValue = ctx.GetInputValue<TfToken>(
            ExecIrTokens->switch_);
    if (switchValue == ExecIrTokens->rig1) {
        return {{
            {ExecIrTokens->rig1Space,
             VtValue(ctx.GetInputValue<GfMatrix4d>(ExecIrTokens->outSpace))},
        }};
    }
    else if (switchValue == ExecIrTokens->rig2) {
        return {{
            {ExecIrTokens->rig2Space,
             VtValue(ctx.GetInputValue<GfMatrix4d>(ExecIrTokens->outSpace))},
        }};
    } else {
        TF_VERIFY(false, "Unexpected switch value '%s'", switchValue.GetText());
        return {{}};
    }
}
