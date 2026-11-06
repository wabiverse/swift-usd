//
// Copyright 2023 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
/// \file OpenEXRCoreUnity.h

#include <OpenEXR/OpenEXRCore/openexr_config.h>

// The internal libdeflate sources are included by OpenEXRCore/compression.c
// itself (guarded by OPENEXR_USE_INTERNAL_DEFLATE) as of OpenEXR 3.4.14, so
// they must not be included here as well -- doing so compiles those
// translation units twice and redefines symbols such as feature_sysctls and
// query_arm_cpu_features in this unity build.

#include <OpenEXR/openexr-c.h>

#include "../attributes.c"
#include "../base.c"
#include "../bytes.c"
#include "../channel_list.c"
#include "../chunk.c"
#include "../coding.c"
#include "../compression.c"
#include "../context.c"
#include "../debug.c"
#include "../decoding.c"
#include "../encoding.c"
#include "../float_vector.c"
#include "../internal_b44_table.c"
#include "../internal_b44_table_init.c"
#include "../internal_b44.c"
#include "../internal_dwa.c"
#include "../internal_dwa_table.c"
#include "../internal_dwa_table_init.c"
#include "../internal_ht.c"
#include "../internal_huf.c"
#include "../internal_piz.c"
#include "../internal_pxr24.c"
#include "../internal_rle.c"
#include "../internal_structs.c"
#include "../internal_zip.c"
#include "../memory.c"
#include "../opaque.c"
#include "../pack.c"
#include "../parse_header.c"
#include "../part_attr.c"
#include "../part.c"
#include "../preview.c"
#include "../std_attr.c"
#include "../string_vector.c"
#include "../string.c"
#include "../unpack.c"
#include "../validation.c"
#include "../write_header.c"
