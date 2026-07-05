/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#ifndef SWIFTUSD_SWIFTOVERLAY_STD_STRING_OVERLAY_H
#define SWIFTUSD_SWIFTOVERLAY_STD_STRING_OVERLAY_H

#include "Ar/resolvedPath.h"
#include "Arch/systemInfo.h"
#include "Plug/registry.h"
#include "Sdf/assetPath.h"
#include "Sdf/layer.h"
#include "Sdf/layerOffset.h"
#include "Sdf/path.h"
#include "Sdf/reference.h"
#include "Tf/token.h"
#include "Tf/type.h"
#include "Usd/attribute.h"
#include "Usd/common.h"
#include "Usd/object.h"
#include "Usd/prim.h"
#include "Usd/references.h"
#include "Usd/stage.h"
#include "Usd/timeCode.h"
#include "UsdShade/shader.h"
#include "Vt/dictionary.h"
#include "Vt/value.h"
#include "pxr/pxrns.h"

/// On Linux/Swift 6.2.1, every `CxxStdlib` overlay initializer for `std::string`
/// (`init(_ string: String)` and `init(_ cString: UnsafePointer<CChar>?)`) triggers
/// a `*** DESERIALIZATION FAILURE ***` while resolving `std::allocator<CChar>`
/// across module boundaries.
///
/// To avoid Swift ever constructing a `std::string` itself, every API that needs
/// one is wrapped here: Swift passes a raw `const char *` (via `withCString`) and
/// the `std::string` is constructed entirely on the C++ side.
namespace Overlay
{
  Pixar::TfToken MakeToken(const char *value);

  const Pixar::TfType &FindTypeByName(const char *name);

  Pixar::SdfPath MakePath(const char *path);
  Pixar::SdfAssetPath MakeAssetPath(const char *path);
  Pixar::SdfReference MakeReference(const char *assetPath, const Pixar::SdfPath &primPath, const Pixar::SdfLayerOffset &layerOffset, const Pixar::VtDictionary &customData);

  void SetDocumentation(const Pixar::SdfLayerHandle &layer, const char *doc);
  void SetDocumentation(const Pixar::UsdPrim &prim, const char *doc);
  void SetDocumentation(const Pixar::UsdAttribute &attr, const char *doc);

  bool SetAttributeString(const Pixar::UsdAttribute &attr, const char *value, const Pixar::UsdTimeCode &time);

  Pixar::UsdStageRefPtr CreateNewStage(const char *identifier, Pixar::UsdStage::InitialLoadSet load);
  Pixar::UsdStageRefPtr CreateInMemoryStage(const char *identifier, Pixar::UsdStage::InitialLoadSet load);
  Pixar::UsdStageRefPtr OpenStage(const char *filePath, Pixar::UsdStage::InitialLoadSet load);

  bool AddReference(Pixar::UsdReferences references, const char *assetPath, const Pixar::SdfPath &primPath, const Pixar::SdfLayerOffset &layerOffset, Pixar::UsdListPosition position);
  bool AddReference(Pixar::UsdReferences references, const char *assetPath, const Pixar::SdfLayerOffset &layerOffset, Pixar::UsdListPosition position);

  Pixar::UsdAttribute CreateIdAttr(const Pixar::UsdShadeShader &shader, const char *defaultValue, bool writeSparsely);
    
  typedef std::vector<std::string> String_Vector;

  std::vector<std::string> MakeStringVector();
  std::vector<std::string> PushBackPath(std::vector<std::string> paths, const char *path);

  // (TODO:@furbytm) move these into own overlay header at some point...
  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, double value);
  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, int value);
  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, float value);
  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, Pixar::TfToken value);
  Pixar::SdfValueTypeName SdfGetValueTypeNameValue(Pixar::SdfValueTypeNameType type);

  /// The reverse direction (`std::string` -> Swift `String`) is just as broken
  /// as the forward direction: `String.init(_ cxxString: std.string)` triggers
  /// the same deserialization failure. So every `std::string` returning getter
  /// is wrapped here too, exposing it as a `const char *` that Swift converts
  /// via `String(cString:)` (a plain Swift API, not `CxxStdlib`).
  const char *GetPathText(const Pixar::SdfPath &path);
  const char *GetPathNameText(const Pixar::SdfPath &path);
  const char *GetTokenText(const Pixar::TfToken &token);
  const char *GetResolvedPathText(const Pixar::ArResolvedPath &path);
  const char *ExportStageToString(const Pixar::UsdStage &stage, bool addSourceFileComment);
  const char *GetTypeName(const Pixar::TfType &type);
  const char *GetCwd();
  const char *GetExecutablePath();
} // namespace Overlay

#endif // SWIFTUSD_SWIFTOVERLAY_STD_STRING_OVERLAY_H
