//
// Copyright 2024 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#include "pxr/pxrns.h"
#include "Tf/pyModule.h"

PXR_NAMESPACE_USING_DIRECTIVE

TF_WRAP_MODULE
{
    // Include non-schema classes here in the format TF_WRAP(CPP_class_name);
    TF_WRAP( HeuristicQuery );
    TF_WRAP( DistanceHeuristicQuery );
    TF_WRAP( ScreenSizeHeuristicQuery );
    
    // Generated Schema classes.  Do not remove or edit the following line.
    #include <UsdLod/generatedSchema.module.h>
}
