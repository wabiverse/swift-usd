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

#include "USDOverlays/StdStringOverlay.h"

namespace Overlay
{
  Pixar::TfToken MakeToken(const char *value)
  {
    return Pixar::TfToken(value);
  }

  const Pixar::TfType &FindTypeByName(const char *name)
  {
    return Pixar::TfType::FindByName(std::string(name));
  }

  Pixar::SdfPath MakePath(const char *path)
  {
    return Pixar::SdfPath(std::string(path));
  }

  Pixar::SdfAssetPath MakeAssetPath(const char *path)
  {
    return Pixar::SdfAssetPath(std::string(path));
  }

  Pixar::SdfReference MakeReference(const char *assetPath, const Pixar::SdfPath &primPath, const Pixar::SdfLayerOffset &layerOffset, const Pixar::VtDictionary &customData)
  {
    return Pixar::SdfReference(std::string(assetPath), primPath, layerOffset, customData);
  }

  void SetDocumentation(const Pixar::SdfLayerHandle &layer, const char *doc)
  {
    layer->SetDocumentation(std::string(doc));
  }

  void SetDocumentation(const Pixar::UsdPrim &prim, const char *doc)
  {
    prim.SetDocumentation(std::string(doc));
  }

  void SetDocumentation(const Pixar::UsdAttribute &attr, const char *doc)
  {
    attr.SetDocumentation(std::string(doc));
  }

  bool SetAttributeString(const Pixar::UsdAttribute &attr, const char *value, const Pixar::UsdTimeCode &time)
  {
    return attr.Set(std::string(value), time);
  }

  Pixar::UsdStageRefPtr CreateNewStage(const char *identifier, Pixar::UsdStage::InitialLoadSet load)
  {
    return Pixar::UsdStage::CreateNew(std::string(identifier), load);
  }

  Pixar::UsdStageRefPtr CreateInMemoryStage(const char *identifier, Pixar::UsdStage::InitialLoadSet load)
  {
    return Pixar::UsdStage::CreateInMemory(std::string(identifier), load);
  }

  Pixar::UsdStageRefPtr OpenStage(const char *filePath, Pixar::UsdStage::InitialLoadSet load)
  {
    return Pixar::UsdStage::Open(std::string(filePath), load);
  }

  Pixar::UsdStageRefPtr OpenStage(const Pixar::SdfLayerHandle &rootLayer, Pixar::UsdStage::InitialLoadSet load)
  {
    return Pixar::UsdStage::Open(rootLayer, load);
  }

  bool AddReference(Pixar::UsdReferences references, const char *assetPath, const Pixar::SdfPath &primPath, const Pixar::SdfLayerOffset &layerOffset, Pixar::UsdListPosition position)
  {
    return references.AddReference(std::string(assetPath), primPath, layerOffset, position);
  }

  bool AddReference(Pixar::UsdReferences references, const char *assetPath, const Pixar::SdfLayerOffset &layerOffset, Pixar::UsdListPosition position)
  {
    return references.AddReference(std::string(assetPath), layerOffset, position);
  }

  Pixar::UsdAttribute CreateIdAttr(const Pixar::UsdShadeShader &shader, const char *defaultValue, bool writeSparsely)
  {
    return shader.CreateIdAttr(Pixar::VtValue(Pixar::TfToken(defaultValue)), writeSparsely);
  }

  std::vector<std::string> MakeStringVector()
  {
    return std::vector<std::string>();
  }

  std::vector<std::string> PushBackPath(std::vector<std::string> paths, const char *path)
  {
    paths.push_back(std::string(path));
    return paths;
  }

  const char *GetPathText(const Pixar::SdfPath &path)
  {
    return path.GetText();
  }

  const char *GetPathNameText(const Pixar::SdfPath &path)
  {
    return path.GetName().c_str();
  }

  const char *GetTokenText(const Pixar::TfToken &token)
  {
    return token.GetText();
  }

  const char *GetResolvedPathText(const Pixar::ArResolvedPath &path)
  {
    return path.GetPathString().c_str();
  }

  const char *ExportStageToString(const Pixar::UsdStage &stage, bool addSourceFileComment)
  {
    static thread_local std::string buf;
    stage.ExportToString(&buf, addSourceFileComment);
    return buf.c_str();
  }

  const char *GetTypeName(const Pixar::TfType &type)
  {
    return type.GetTypeName().c_str();
  }

  const char *GetCwd()
  {
    static thread_local std::string buf;
    buf = Pixar::ArchGetCwd();
    return buf.c_str();
  }

  const char *GetExecutablePath()
  {
    static thread_local std::string buf;
    buf = Pixar::ArchGetExecutablePath();
    return buf.c_str();
  }

  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, double value)
  {
    return stage.SetMetadata(key, Pixar::VtValue(value));
  }

  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, int value)
  {
    return stage.SetMetadata(key, Pixar::VtValue(value));
  }

  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, float value)
  {
    return stage.SetMetadata(key, Pixar::VtValue(value));
  }

  bool StageSetMetadata(const Pixar::UsdStage &stage, const Pixar::TfToken &key, Pixar::TfToken value)
  {
    return stage.SetMetadata(key, Pixar::VtValue(value));
  }

  Pixar::SdfValueTypeName SdfGetValueTypeNameValue(Pixar::SdfValueTypeNameType type)
  {
    return Pixar::SdfGetValueTypeName(type);
  }
} // namespace Overlay
