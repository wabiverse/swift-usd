//
// Copyright 2023 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
/// \file OpenEXRCoreUnity.h

#include <OpenEXR/OpenEXRCore/openexr_config.h>

#include <OpenEXR/deflate/lib/lib_common.h>
#include <OpenEXR/deflate/common_defs.h>
#include "../OpenEXR/deflate/lib/utils.c"
#include "../OpenEXR/deflate/lib/arm/cpu_features.c"
#include "../OpenEXR/deflate/lib/x86/cpu_features.c"
#include "../OpenEXR/deflate/lib/deflate_compress.c"
#undef BITBUF_NBITS
#include "../OpenEXR/deflate/lib/deflate_decompress.c"
#include "../OpenEXR/deflate/lib/adler32.c"
#include "../OpenEXR/deflate/lib/zlib_compress.c"
#include "../OpenEXR/deflate/lib/zlib_decompress.c"

#include <OpenEXR/openexr-c.h>

#include "../attributes.c"
#include "../base.c"
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
#include "../internal_b44.c"
#include "../internal_dwa.c"
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
