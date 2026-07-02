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

import ArgumentParser
import Foundation

struct UpdateCommand: AsyncCommand
{
  static let configuration = CommandConfiguration(
    commandName: "update",
    abstract: "Update the OpenUSD version in the current package."
  )

  /// Arguments in common with the run command.
  @OptionGroup
  var arguments: UpdateArguments

  init()
  {
    _arguments = OptionGroup()
  }

  init(arguments: OptionGroup<UpdateArguments>)
  {
    _arguments = arguments
  }

  static func validateArguments(_: UpdateArguments) -> Bool
  {
    // validate parameters
    true
  }

  func wrappedRun() async throws
  {
    // get the package directory.
    var packageDirectory = URL(fileURLWithPath: ".")
    if let selectedPackage = arguments.packageDirectory
    {
      packageDirectory = selectedPackage
    }

    // get the package directory path.
    let pkgDir = packageDirectory.path

    // remove possibly existing openusd directory.
    if FileManager.default.fileExists(atPath: "\(pkgDir)/.build/OpenUSD", isDirectory: nil)
    {
      try FileManager.default.removeItem(atPath: "\(pkgDir)/.build/OpenUSD")
    }

    // start timing
    let elapsed = try await Stopwatch.time
    {
      // 1. clone pixar official openusd repository.
      if let usdVersion = arguments.usdVersion {
        try Command.git.run(with: ["clone", "--branch", usdVersion, "https://github.com/PixarAnimationStudios/OpenUSD.git", "\(pkgDir)/.build/OpenUSD"])
      } else {
        log.info("no openusd version provided, updating openusd to the latest revision from the 'dev' branch.")
        try Command.git.run(with: ["clone", "https://github.com/PixarAnimationStudios/OpenUSD.git", "\(pkgDir)/.build/OpenUSD"])
      }

      // 2. collect basenames of files enumerate() treats specially (python-only, test-only).
      let exclusions = SourceExclusions(checkoutRoot: "\(pkgDir)/.build/OpenUSD")

      // 3. update all usd source in this package, in parallel.
      async let bse = try Pxr.base.enumerate(packagePath: pkgDir, exclusions: exclusions)
      async let img = try Pxr.imaging.enumerate(packagePath: pkgDir, exclusions: exclusions)
      async let usd = try Pxr.usd.enumerate(packagePath: pkgDir, exclusions: exclusions)
      async let uim = try Pxr.usdImaging.enumerate(packagePath: pkgDir, exclusions: exclusions)
      async let exc = try Pxr.exec.enumerate(packagePath: pkgDir, exclusions: exclusions)
      async let val = try Pxr.usdValidation.enumerate(packagePath: pkgDir, exclusions: exclusions)

      // 4. wait for all usd source to be updated.
      let _ = try await [bse, img, usd, uim, exc, val]
    }

    // output elapsed time
    log.info("done in \(elapsed.secondsString). openusd source updated at '\(pkgDir)'.")
  }
}

public struct SourceExclusions: Sendable
{
  let pythonOnly: Set<String>
  let testOnly: Set<String>

  public init(checkoutRoot: String)
  {
    pythonOnly = collectPythonOnlyBasenames(checkoutRoot: checkoutRoot)
    testOnly = collectTestingFiles(checkoutRoot: checkoutRoot)
  }
}

private func collectTestingFiles(checkoutRoot: String) -> Set<String>
{
  var basenames: Set<String> = ["examples_usd", "examples_usdGeom", "stageSceneIndexFactory_execOff"]

  guard let regex = try? NSRegularExpression(pattern: "^[a-z]+Test_[A-Z]"),
        let enumerator = FileManager.default.enumerator(atPath: "\(checkoutRoot)/pxr")
  else { return basenames }

  for entry in enumerator
  {
    guard let relPath = entry as? String else { continue }

    var name = (relPath as NSString).lastPathComponent
    guard let dotIndex = name.lastIndex(of: ".") else { continue }
    name = String(name[name.startIndex..<dotIndex])

    let range = NSRange(name.startIndex..<name.endIndex, in: name)
    if regex.firstMatch(in: name, range: range) != nil
    {
      basenames.insert(name)
    }
  }

  return basenames
}

private func collectPythonOnlyBasenames(checkoutRoot: String) -> Set<String>
{
  var basenames: Set<String> = []

  let pythonListNames: Set<String> = [
    "PYTHON_PUBLIC_CLASSES", "PYTHON_PRIVATE_CLASSES",
    "PYTHON_PUBLIC_HEADERS", "PYTHON_PRIVATE_HEADERS",
  ]

  func isListName(_ s: String) -> Bool
  {
    guard let first = s.first, first.isUppercase else { return false }
    return s.allSatisfy { $0.isUppercase || $0.isNumber || $0 == "_" }
  }

  guard let enumerator = FileManager.default.enumerator(atPath: "\(checkoutRoot)/pxr")
  else { return basenames }

  for entry in enumerator
  {
    guard let relPath = entry as? String, relPath.hasSuffix("CMakeLists.txt"),
          let contents = try? String(contentsOfFile: "\(checkoutRoot)/pxr/\(relPath)", encoding: .utf8)
    else { continue }

    var currentList: String? = nil
    for rawLine in contents.components(separatedBy: "\n")
    {
      let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
      if trimmed.isEmpty { currentList = nil; continue }
      if isListName(trimmed) { currentList = trimmed; continue }

      guard let list = currentList else { continue }

      if list == "PYMODULE_CPPFILES"
      {
        if trimmed.contains("wrap") || trimmed.contains("module") { continue }
      }
      else if !pythonListNames.contains(list)
      {
        continue
      }

      var name = (trimmed as NSString).lastPathComponent
      if let dotIndex = name.lastIndex(of: ".")
      {
        name = String(name[name.startIndex..<dotIndex])
      }
      basenames.insert(name)
    }
  }

  return basenames
}

public enum Pxr: String, CaseIterable
{
  case base
  case imaging
  case usd
  case usdImaging
  case exec
  case usdValidation

  public func enumerate(packagePath: String, exclusions: SourceExclusions) async throws -> [URL]
  {
    guard let list = FileManager.default.enumerator(atPath: "\(packagePath)/.build/OpenUSD/pxr/\(rawValue)")
    else { log.critical("Failed to list \(rawValue) directory."); return [] }

    let existingResourceDirs = resourceDirectories(packagePath: packagePath)
    try nukeStaleTargetFiles(packagePath: packagePath, resourceDirectories: existingResourceDirs)

    let updatedFiles: [URL] = try list.compactMap
    { pxrPath in

      let suffix = path(from: pxrPath).split(separator: "pxr/\(rawValue)/").last ?? ""
      let source = URL(fileURLWithPath: ".build/OpenUSD/pxr/\(rawValue)/\(path(from: pxrPath))")
      let suffixParts = suffix.split(separator: "/")

      // plugin/ is a grouping dir; the actual target name is the second component.
      let isPluginLibrary = suffixParts.first == "plugin"
      var target = String((isPluginLibrary ? suffixParts.dropFirst().first : suffixParts.first) ?? "").capitalized
      ensureCasing(for: &target)

      // skip plugins with no Sources/<Target> (hioAvif, hdEmbree, etc.).
      let isUnbuiltPlugin = isPluginLibrary && !FileManager.default.fileExists(atPath: "\(packagePath)/Sources/\(target)")

      #if os(Windows)
        let platformExcludes = false
      #else
        let platformExcludes = source.path.lowercased().contains("msinttypes")
      #endif
      if source.path.contains("testenv") ||
        source.path.lowercased().contains("cmakelists") ||
        source.path.lowercased().contains("pch.h") ||
        source.path.lowercased().contains(".template.") ||
        source.path.lowercased().contains("codegentemplates") ||
        source.path.lowercased().contains("unittest") ||
        exclusions.testOnly.contains(source.deletingPathExtension().lastPathComponent) ||
        platformExcludes ||
        isUnbuiltPlugin
      { return nil }

      try createTargetDirectories(packagePath: packagePath, target: target)
      try createPythonDirectories(packagePath: packagePath, target: target)

      var sourceFile = source.lastPathComponent

      // SwiftPM has no per-file compile-flag override, so give this file
      // a ".mm" extension to get objective-c++ mode from the compiler driver
      // on every platform (this should be fine to do on Android, Linux, and
      // Windows).
      if target == "HgiInterop", sourceFile == "hgiInterop.cpp"
      {
        sourceFile = "hgiInterop.mm"
      }

      if ["m", "mm", "cpp", "cc", "c", "cxx"].contains(source.pathExtension)
      {
        if sourceFile.contains("wrap") || sourceFile.contains("module")
        {
          let dest = URL(fileURLWithPath: "\(packagePath)/Python/Py\(target)/\(sourceFile)")
          let priorPy = try? String(contentsOf: dest, encoding: .utf8)
          try? FileManager.default.removeItem(at: dest)
          try FileManager.default.moveItem(at: source, to: dest)
          if updateSource(fileURL: dest, target: target, exclusions: exclusions, priorContent: priorPy) {
            log.info("updating python module: \(dest.path)")
          }

          return dest
        }
        else
        {
          let dest = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/\(sourceFile)")
          let priorSrc = try? String(contentsOf: dest, encoding: .utf8)
          try? FileManager.default.removeItem(at: dest)
          try FileManager.default.moveItem(at: source, to: dest)
          if updateSource(fileURL: dest, target: target, exclusions: exclusions, priorContent: priorSrc) {
            log.info("updating source: \(dest.path)")
          }

          return dest
        }
      }

      // CMake configure_file() templates (ex. "impl.h.in" -> "impl.h").
      // "pxr/pxr.h.in" is handled by hand as "pxr/pxrns.h" and lives outside
      // these enumerated package directories, so it never reaches here.
      let isConfigTemplate = source.pathExtension == "in" && source.deletingPathExtension().pathExtension == "h"

      if ["h", "hpp", "hxx"].contains(source.pathExtension) || isConfigTemplate
      {
        if isConfigTemplate
        {
          // configure_file() writes its output without the trailing ".in".
          sourceFile = source.deletingPathExtension().lastPathComponent
        }

        // pegtl's internal/ and contrib/ headers share basenames with
        // top-level pegtl/*.hpp (ex. utf8.hpp) -- flattening them together
        // lets one clobber the other. preserve internal/ and contrib/ as
        // real subdirectories, matching upstream's layout.
        var preservesSubdirectory = false
        if target == "Pegtl"
        {
          let pegtlPath = suffix.split(separator: "/").dropFirst(2).joined(separator: "/")
          if pegtlPath.hasPrefix("internal/") || pegtlPath.hasPrefix("contrib/")
          {
            sourceFile = pegtlPath
            preservesSubdirectory = true
          }
        }

        // Tf vendors third-party libs under "pxr<Vendor>/" (ex.
        // pxrTslRobinMap/robin_map.h), included elsewhere via
        // "Tf/pxr<Vendor>/...". preserve as a real subdirectory for HEADERS
        // only -- flattening headers leaves those includes resolving to stale
        // copies. Source files are flattened to top-level to avoid duplicate
        // symbol errors when both the vendor subdir copy and a top-level copy
        // get compiled (e.g. pxrLZ4/lz4.cpp vs lz4.cpp, pxrDoubleConversion/bignum.cc vs bignum.cc).
        else if target == "Tf"
        {
          let tfPath = suffix.split(separator: "/").dropFirst(1).joined(separator: "/")
          if let vendorDir = tfPath.split(separator: "/").first,
            vendorDir.hasPrefix("pxr"), vendorDir.dropFirst(3).first?.isUppercase == true
          {
            let isHeader = ["h", "hpp", "hxx"].contains(source.pathExtension)
            if isHeader
            {
              sourceFile = tfPath
              preservesSubdirectory = true
            }
            // source files (.cc/.cpp) stay at top level: pxrLZ4/lz4.cpp -> lz4.cpp
          }
        }
        
        else if target == "Gf"
        {
          let gfPath = suffix.split(separator: "/").dropFirst(1).joined(separator: "/")
          if gfPath.hasPrefix("nc/")
          {
            sourceFile = gfPath
            preservesSubdirectory = true
          }
        }

        // rapidjson's own headers #include each other with paths relative
        // to "rapidjson/" (ex. "internal/meta.h", "../rapidjson.h",
        // "error/error.h"), and Js/json.cpp includes them as
        // "rapidjson/...". preserve rapidjson/ as a real subdirectory,
        // matching upstream's layout.
        else if target == "Js"
        {
          let jsPath = suffix.split(separator: "/").dropFirst(1).joined(separator: "/")
          if jsPath.hasPrefix("rapidjson/")
          {
            sourceFile = jsPath
            preservesSubdirectory = true
          }
        }

        // stbImage.cpp includes the vendored stb headers as "Hio/stb/...".
        // preserve stb/ as a real subdirectory, matching upstream's layout.
        else if target == "Hio"
        {
          let hioPath = suffix.split(separator: "/").dropFirst(1).joined(separator: "/")
          if hioPath.hasPrefix("stb/")
          {
            sourceFile = hioPath
            preservesSubdirectory = true
          }
        }

        // pxr headers must not have the name of the umbrella header, since
        // that collides on case-insensitive filesystems (ex. "tf.h" vs
        // the generated "Tf.h").
        if sourceFile.lowercased() == "\(target.lowercased()).h"
        {
          // so we suffix them with (ex. ar.h -> arImpl.h).
          sourceFile = "\(target.lowercased())Impl.h"
        }

        // workTBB/impl.h would collide with impl.h.in's configured
        // Work/impl.h output -- rename it. Patch.configureTemplate() points
        // @PXR_WORK_IMPL_HEADER@ at this same name.
        if source.path.hasSuffix("/workTBB/impl.h")
        {
          sourceFile = "implTBB.h"
        }

        let dest = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/include/\(target)/\(sourceFile)")

        if isConfigTemplate
        {
          // configure_file(): resolve CMake @VAR@ placeholders before the
          // normal include-rewriting pipeline runs.
          var template = try String(contentsOf: source, encoding: .utf8)
          Patch.configureTemplate(to: &template)
          try template.write(to: source, atomically: true, encoding: .utf8)
        }

        // ensure subdirectories (ex. Pegtl/internal/) exist before moving.
        try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)

        let priorHeader = try? String(contentsOf: dest, encoding: .utf8)
        try? FileManager.default.removeItem(at: dest)
        try FileManager.default.moveItem(at: source, to: dest)
        if updateSource(fileURL: dest, target: target, exclusions: exclusions, priorContent: priorHeader) {
          log.info("updating header: \(dest.path)")
        }

        // headers like Tf/instantiateSingleton.h are meant to be included
        // once, directly by the .cpp that needs them -- keep out of umbrella.
        let blacklistedIncludes = [
          "tf.h",
          "instantiatePool.h",
          "instantiateSingleton.h",
          "instantiateStacked.h",
          "instantiateType.h",
          "pyModule.h",
          "CLI11.h",
          // X-macro data fragment, only valid when included inside an enum/switch body.
          "crateDataTypes.h",
          // Private implementation header: includes crateDataTypes.h inside an enum
          // body which Clang modules can't handle (converts #include to module import).
          "crateFile.h",
          // Python boost binding utility header (uses pxr_boost::python, PyObject).
          "wrapUtils.h",
          // TF_WRAP(...) fragment file, only valid inside a Python module registration
          // body, not a standalone compilable header.
          "generatedSchema.module.h",
          // Raw data fragments - designed to be #included inside array/struct
          // declarations in .cpp files; not valid as standalone headers.
          "ilmbase_eLut.h",
          "ilmbase_toFloat.h",
          // Private nested struct definition for GfColorSpace::_Data; only valid
          // after GfColorSpace is declared (included mid-class in colorSpace.h).
          "colorSpace_data.h",
          // This is a special header include that requires VT_ADD_EXT_VISIT_VALUE_TYPE
          // to be defined prior to including, which is not an umbrella header compatible
          // include.
          "addExtVisitValueType.h"
        ]
        // Use exact filename match - substring match on dest.path would
        // accidentally catch files whose names end in a blacklisted name
        // (e.g. "tf.h" would match "quatf.h" and "dualQuatf.h").
        let includeOnceHeader = blacklistedIncludes.contains(dest.lastPathComponent)
        
        // Garch's per-platform GL headers (ex. glPlatformContextDarwin.h,
        // glPlatformDebugWindowGLX.h) would pull in Windows.h/GL/glx.h on
        // every platform if added to the umbrella -- detect them by their
        // <Name><Platform>.h naming and leave them out, they're reachable
        // via their dispatcher header or own .cpp/.mm.
        let platformVariantHeader: Bool =
        {
          let baseName = (sourceFile as NSString).deletingPathExtension
          guard sourceFile.hasSuffix(".h") else { return false }
          
          if baseName.hasPrefix("glPlatform") {
            return ["Darwin", "GLX", "Windows"].contains { baseName.hasSuffix($0) }
          }
          
          // & not supporting vulkan quite yet.
          return baseName.lowercased().hasPrefix("hgivulkan") || baseName.lowercased().hasPrefix("vulkan")
        }()

        if !preservesSubdirectory && !includeOnceHeader && !platformVariantHeader
        {
          // generate this target's umbrella header, appending all its
          // headers to this single file.
          let umbrellaPath = "\(packagePath)/Sources/\(target)/include/\(target)/\(target).h"
          let umbrellaURL = URL(fileURLWithPath: umbrellaPath)
          generateUmbrellaHeader(fileURL: umbrellaURL, for: target, appending: sourceFile)
          
          // various umbrella header modifications
          switch target {
            case "HgiInterop":
              var umbrellaSrc = try String(contentsOf: umbrellaURL, encoding: .utf8)
              // HgiInterop/metal.h is only for macOS.
              umbrellaSrc = umbrellaSrc.replacingOccurrences(
                of: "#include <HgiInterop/metal.h>",
                with: "#if defined(__APPLE__) && defined(__has_include) && __has_include(<AppKit/AppKit.h>)\n#include <HgiInterop/metal.h>\n#endif"
              )
              umbrellaSrc = umbrellaSrc.replacingOccurrences(
                of: "#include <HgiInterop/hgiinteropImpl.h>",
                with: "#include <HgiInterop/hgiInteropImpl.h>"
              )
              try umbrellaSrc.write(to: umbrellaURL, atomically: true, encoding: .utf8)
            default:
              break
          }
        }

        return dest
      }

      let libRelative = (isPluginLibrary ? suffixParts.dropFirst(2) : suffixParts.dropFirst(1)).joined(separator: "/")

      var resourceRelPath: String? = nil
      if ["plugInfo.json", "schema.usda", "generatedSchema.usda"].contains(libRelative) || libRelative.hasPrefix("examples/")
      {
        resourceRelPath = "Resources/\(libRelative)"
      }
      else if libRelative.hasPrefix("shaders/") || libRelative.hasPrefix("textures/")
      {
        resourceRelPath = libRelative
      }

      if let resourceRelPath,
         let resourceSubdir = resourceRelPath.split(separator: "/").first,
         existingResourceDirs.contains("\(target)/\(resourceSubdir)")
      {
        let dest = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/\(resourceRelPath)")

        try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
        let priorResource = try? String(contentsOf: dest, encoding: .utf8)
        try? FileManager.default.removeItem(at: dest)
        try FileManager.default.moveItem(at: source, to: dest)

        if ["json", "usda", "usd", "glslfx"].contains(source.pathExtension.lowercased())
        {
          var resourceSrc = try String(contentsOf: dest, encoding: .utf8)

          if libRelative == "plugInfo.json"
          {
            Patch.pluginfoTemplate(to: &resourceSrc)
          }

          Patch.apply(to: &resourceSrc, fileURL: dest, target: target, relativePath: resourceRelPath)
          Patch.glslfxToolsPaths(to: &resourceSrc)

          if libRelative == "plugInfo.json"
          {
            Patch.pluginfoName(to: &resourceSrc, target: target)
          }
          if libRelative == "schema.usda" || libRelative == "generatedSchema.usda"
          {
            Patch.schemaUsda(to: &resourceSrc, target: target)
          }

          if priorResource != resourceSrc {
            try resourceSrc.write(to: dest, atomically: true, encoding: .utf8)
            log.info("updating resource: \(dest.path)")
          }
        }
        else
        {
          // binary resource (ex. a texture) -- substitute a hand-edited
          // override wholesale, if one exists for this target.
          let overridePath = (Bundle.module.resourceURL?.path ?? ".") + "/Resources/\(target)/\(resourceRelPath)"
          if FileManager.default.fileExists(atPath: overridePath)
          {
            try? FileManager.default.removeItem(at: dest)
            try FileManager.default.copyItem(atPath: overridePath, toPath: dest.path)
          }
          // always log binary resources can't cheaply diff binary content
          log.info("updating resource: \(dest.path)")
        }

        return dest
      }

      return nil
    }

    try restoreResourceOnlyFiles(packagePath: packagePath)

    return updatedFiles
  }

  private func targets(packagePath: String) -> [String]
  {
    let pxrDir = "\(packagePath)/.build/OpenUSD/pxr/\(rawValue)"
    guard let entries = try? FileManager.default.contentsOfDirectory(atPath: pxrDir)
    else { return [] }

    var result: [String] = []

    for entry in entries
    {
      // recurse into plugin/, it's a grouping dir, not a target itself.
      if entry == "plugin"
      {
        if let pluginEntries = try? FileManager.default.contentsOfDirectory(atPath: "\(pxrDir)/plugin")
        {
          for pluginEntry in pluginEntries
          {
            var target = pluginEntry.capitalized
            ensureCasing(for: &target)
            result.append(target)
          }
        }
        continue
      }

      var target = entry.capitalized
      ensureCasing(for: &target)
      result.append(target)
    }

    return result
  }

  private func resourceDirectories(packagePath: String) -> Set<String>
  {
    var result: Set<String> = []

    for target in targets(packagePath: packagePath)
    {
      for subdir in ["Resources", "shaders", "textures"]
      {
        if FileManager.default.fileExists(atPath: "\(packagePath)/Sources/\(target)/\(subdir)")
        {
          result.insert("\(target)/\(subdir)")
        }
      }
    }

    return result
  }

  // Removes generated headers/sources so stale upstream renames/deletes don't survive across runs.
  private func nukeStaleTargetFiles(packagePath: String, resourceDirectories: Set<String>) throws
  {
    let sourceExtensions: Set<String> = ["m", "mm", "cpp", "cc", "c", "cxx"]

    for target in targets(packagePath: packagePath)
    {
      let targetDir = "\(packagePath)/Sources/\(target)"
      guard FileManager.default.fileExists(atPath: targetDir, isDirectory: nil) else { continue }

      try? FileManager.default.removeItem(atPath: "\(targetDir)/include/\(target)")

      for subdir in ["Resources", "shaders", "textures"] where resourceDirectories.contains("\(target)/\(subdir)")
      {
        try? FileManager.default.removeItem(atPath: "\(targetDir)/\(subdir)")
      }

      guard let topLevel = try? FileManager.default.contentsOfDirectory(atPath: targetDir)
      else { continue }

      for item in topLevel where sourceExtensions.contains((item as NSString).pathExtension)
      {
        try? FileManager.default.removeItem(atPath: "\(targetDir)/\(item)")
      }

      // Tf vendor subdirs (pxrLZ4/, pxrDoubleConversion/) previously held
      // source files that are now flattened to top-level. Nuke any stale
      // subdirectory sources to prevent duplicate-symbol link errors.
      if target == "Tf"
      {
        for vendorDir in ["pxrLZ4", "pxrDoubleConversion"]
        {
          let vendorPath = "\(targetDir)/\(vendorDir)"
          guard let vendorContents = try? FileManager.default.contentsOfDirectory(atPath: vendorPath)
          else { continue }
          for item in vendorContents where sourceExtensions.contains((item as NSString).pathExtension)
          {
            try? FileManager.default.removeItem(atPath: "\(vendorPath)/\(item)")
          }
        }
      }
    }
  }

  // Copies Resources/<Target>/ files with no upstream counterpart into Sources/<Target>/ (e.g. swiftInterop.h).
  private func restoreResourceOnlyFiles(packagePath: String) throws
  {
    guard let resourceRoot = Bundle.module.resourceURL
    else { return }

    for target in targets(packagePath: packagePath)
    {
      let resourceDir = resourceRoot.appendingPathComponent(target)
      guard let files = try? FileManager.default.contentsOfDirectory(atPath: resourceDir.path)
      else { continue }

      for file in files
      {
        let ext = (file as NSString).pathExtension
        let isHeader = ["h", "hpp", "hxx"].contains(ext)
        let isSource = ["m", "mm", "cpp", "cc", "c", "cxx"].contains(ext)
        guard isHeader || isSource else { continue }

        let dest = isHeader
          ? URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/include/\(target)/\(file)")
          : URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/\(file)")

        guard !FileManager.default.fileExists(atPath: dest.path) else { continue }

        try createTargetDirectories(packagePath: packagePath, target: target)
        try FileManager.default.copyItem(at: resourceDir.appendingPathComponent(file), to: dest)
        log.info("restoring resource-only file: \(dest.path)")

        if isHeader
        {
          let umbrellaPath = "\(packagePath)/Sources/\(target)/include/\(target)/\(target).h"
          generateUmbrellaHeader(fileURL: URL(fileURLWithPath: umbrellaPath), for: target, appending: file)
        }
      }

      // restore resource files (ex. "shaders/widgetShader.glslfx") with no
      // upstream counterpart -- nothing for enumerate() to copy.
      for subdir in ["Resources", "shaders", "textures"]
      {
        let subdirURL = resourceDir.appendingPathComponent(subdir)
        guard let enumerator = FileManager.default.enumerator(atPath: subdirURL.path)
        else { continue }

        for entry in enumerator
        {
          guard let relPath = entry as? String else { continue }

          let source = subdirURL.appendingPathComponent(relPath)
          var isDirectory: ObjCBool = false
          guard FileManager.default.fileExists(atPath: source.path, isDirectory: &isDirectory), !isDirectory.boolValue
          else { continue }

          let dest = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/\(subdir)/\(relPath)")
          guard !FileManager.default.fileExists(atPath: dest.path) else { continue }

          try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
          try FileManager.default.copyItem(at: source, to: dest)
          log.info("restoring resource-only file: \(dest.path)")
        }
      }
    }
  }

  private func generateUmbrellaHeader(fileURL: URL, for target: String, appending header: String)
  {
    do
    {
      // get the existing contents of the umbrella header, if any.
      var umbrellaHeader = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

      // check for the include guard (ex. '__PXR_BASE_ARCH_H__').
      let includeGuard = "__PXR_\(rawValue.uppercased())_\(target.uppercased())_H__"
      let skeletonPath = (Bundle.module.resourceURL?.path ?? ".") + "/Resources/\(target)/\(target).h"
      let skeleton = try? String(contentsOfFile: skeletonPath, encoding: .utf8)

      if !umbrellaHeader.contains("// __PXR_HEADERS__"), let skeleton, skeleton.contains("// __PXR_HEADERS__")
      {
        // some umbrellas have hand-edited structure (ex. Arch.h's
        // "#if defined(__cplusplus)" split) that a prior flattened
        // regeneration may have lost -- restore it from the skeleton in
        // Resources, which carries a "// __PXR_HEADERS__" marker for
        // where to insert.
        umbrellaHeader = skeleton
      }
      else if let guardRange = umbrellaHeader.range(of: "#ifndef \(includeGuard)")
      {
        // discard anything before the guard -- this path may collide
        // (case-insensitively) with a leftover pristine header (ex. tf.h).
        umbrellaHeader = String(umbrellaHeader[guardRange.lowerBound...])
      }
      else if let skeleton
      {
        umbrellaHeader = skeleton
      }
      else
      {
        // create the include guard opener if it does not exist.
        umbrellaHeader = "#ifndef \(includeGuard)\n#define \(includeGuard)\n\n// \(target)\n"
      }

      // Tf umbrella: pxrTslRobinMap must precede all other Tf headers so dependent modules see it via the module system.
      if target == "Tf", !umbrellaHeader.contains("<Tf/pxrTslRobinMap/robin_map.h>")
      {
        let mark = "#define \(includeGuard)\n"
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: mark, with: "\(mark)#include <Tf/pxrTslRobinMap/robin_map.h>\n#include <Tf/pxrTslRobinMap/robin_set.h>\n")
      }

      if umbrellaHeader.contains("#include <\(target)/\(header)>")
      {
        // already present, leave as-is.
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "#include <\(target)/\(header)>", with: "#include <\(target)/\(header)>")
      }
      else if umbrellaHeader.contains("// __PXR_HEADERS__")
      {
        // insert at the marker, preserving hand-edited structure around it.
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "// __PXR_HEADERS__", with: "#include <\(target)/\(header)>\n// __PXR_HEADERS__")
      }
      else
      {
        // append new header entries.
        umbrellaHeader = umbrellaHeader.appending("#include <\(target)/\(header)>\n")
      }

      // check for the closing include guard (ex. '__PXR_BASE_ARCH_H__').
      if umbrellaHeader.contains("#endif  // \(includeGuard)") || umbrellaHeader.contains("#endif // \(includeGuard)")
      {
        // remove the closing guard -- it may no longer be at the bottom,
        // and re-running shouldn't keep appending blank lines.
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "#endif  // \(includeGuard)\n", with: "")
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "#endif // \(includeGuard)\n", with: "")
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "#endif  // \(includeGuard)", with: "")
        umbrellaHeader = umbrellaHeader.replacingOccurrences(of: "#endif // \(includeGuard)", with: "")

        // re-append it to the end of the file.
        umbrellaHeader = umbrellaHeader.appending("#endif  // \(includeGuard)\n")
      }
      else
      {
        // append the closing include guard.
        umbrellaHeader = umbrellaHeader.appending("#endif  // \(includeGuard)\n")
      }

      // write the modified file contents back out to the umbrella header.
      try umbrellaHeader.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    catch
    {
      log.error("error: failed to generate umbrella header '\(fileURL.path)'. \(error.localizedDescription).")
    }
  }

  @discardableResult
  private func updateSource(fileURL: URL, target: String, exclusions: SourceExclusions, priorContent: String? = nil) -> Bool
  {
    do
    {
      var pxrSrc = try String(contentsOf: fileURL, encoding: .utf8)

      /* apply any/all potential patches to upstream source files. */

      Patch.headers(to: &pxrSrc)
      Patch.xmacroFragmentHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.fileSystemHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.tfIteratorHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.tfSmallVectorHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      
      // exposes openusd c++ types to swift, complete with proper refcounting with ARC.
      Patch.tfRefBaseHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.hgi(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.hgiMetal(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.hgiGL(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.arResolver(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.usdStageCacheContext(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.usdImagingGL(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.execUsd(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.plugRegistry(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      
      // cleans up openusd c++ enums for clean swifty apis.
      Patch.sdfTypes(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.usdCommon(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.xformOp(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.xformCommonAPI(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      
      Patch.predicateExpressionParserHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.platformGuardedSource(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.archDarwinHeaders(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.archAndroid(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.garchAndroid(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.backPlateAPI(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.arcRetainReleaseGuards(to: &pxrSrc, fileExtension: fileURL.pathExtension)
      Patch.pythonIncludes(to: &pxrSrc)
      Patch.pythonGuards(to: &pxrSrc, fileBaseName: fileURL.deletingPathExtension().lastPathComponent, pythonOnlyBasenames: exclusions.pythonOnly)
      Patch.addMissingTokens(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent, target: target)
      Patch.apply(to: &pxrSrc, fileURL: fileURL, target: target)

      /* 1. match includes such as:
       * #include "[pxr/base/tf]/token.h"
       * #include "[pxr/imaging/glf]/texture.h"
       * #include "[pxr/usd/sdf]/layer.h"
       * #include "[pxr/usdImaging/hd]/engine.h"
       * #include "[pxr/usd/plugin/usdAbc]/alembicData.h"
       * #include "[pxr/exec/execIr]/tokens.h" */
      let includeMatch = /(?:\G(?!\A)\s*,\s*|\b(?:pxr\/base\/|pxr\/imaging\/|pxr\/usd\/|pxr\/usdImaging\/|pxr\/exec\/|pxr\/usdValidation\/)+(?:plugin\/)?)(\w+)/
      while let match = try includeMatch.firstMatch(in: pxrSrc)
      {
        /* 2. replace include with capitalized version.
         * #include "[pxr/base/tf]/token.h"        -> #include "Tf/token.h"
         * #include "[pxr/imaging/glf]/texture.h"  -> #include "Glf/texture.h"
         * #include "[pxr/usd/sdf]/layer.h"        -> #include "Sdf/layer.h"
         * #include "[pxr/usdImaging/hd]/engine.h" -> #include "Hd/engine.h"
         * #include "[pxr/usd/plugin/usdAbc]/alembicData.h" -> #include "UsdAbc/alembicData.h" */
        let include = pxrSrc[match.range]
        var newInclude = (include.split(separator: "/").last ?? "").capitalized

        ensureCasing(for: &newInclude)
        pxrSrc = pxrSrc.replacingOccurrences(of: include, with: newInclude)
      }

      // collapse vendored library include paths that end up doubled after
      // the capitalization above (ex. "Pegtl/pegtl/config.hpp" -> "Pegtl/config.hpp").
      Patch.vendoredIncludes(to: &pxrSrc, target: target)

      // rewrite references to a pristine header that collides (case-
      // insensitively) with this target's generated umbrella header, since
      // such headers are renamed on disk (ex. "Tf/tf.h" -> "Tf/tfImpl.h").
      Patch.collidingUmbrellaInclude(to: &pxrSrc, target: target)
      
      // rewrite same-directory double-quote includes to angle-bracket module
      // includes, required by SwiftPM's layout where all headers live under
      // include/<Target>/. For files in a preserved subdirectory (e.g.
      // Pegtl/internal/), pass the subdirectory so intra-subdir includes
      // resolve to <Target/subdir/file> instead of the flattened <Target/file>.
      let includeRoot = "include/\(target)/"
      let subdirectory: String? = {
        let p = fileURL.path
        guard let r = p.range(of: includeRoot) else { return nil }
        let rel = String(p[r.upperBound...])  // e.g. "internal/rules.hpp" or "foo.h"
        let parts = rel.split(separator: "/")
        guard parts.count > 1 else { return nil }
        return parts.dropLast().joined(separator: "/")
      }()
      Patch.sameDirectoryIncludes(to: &pxrSrc, target: target, subdirectory: subdirectory)

      // because plain-C header/source code should not bring in Arch's entire
      // C++ clang module, which is problematic.
      Patch.nanocolorHeader(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.openexrCSource(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      
      Patch.materialXShaderGen(to: &pxrSrc, fileBaseName: fileURL.lastPathComponent)
      Patch.glslfxToolsPaths(to: &pxrSrc)

      let changed = priorContent.map { $0 != pxrSrc } ?? true
      try pxrSrc.write(to: fileURL, atomically: true, encoding: .utf8)

      // hgiInterop.mm is guarded defined(__APPLE__); mirror it as hgiInterop.cpp
      // with the inverse guard so non-Apple platforms get plain C++, this is
      // required because linux debug builds otherwise have linker errors with:
      //
      // error: undefined reference to '__gnu_objc_personality_v0'
      //
      // because the .mm extension makes clang compile it as objc++ on linux,
      // which emits DWARF unwind info referencing __gnu_objc_personality_v0
      // from libobjc.
      if fileURL.lastPathComponent == "hgiInterop.mm" {
        let cppURL = fileURL.deletingLastPathComponent().appendingPathComponent("hgiInterop.cpp")
        let cppSrc = pxrSrc
          .replacingOccurrences(of: "#if defined(__APPLE__)\n\n", with: "#if !defined(__APPLE__)\n\n")
          .replacingOccurrences(of: "\n#endif // defined(__APPLE__)\n", with: "\n#endif // !defined(__APPLE__)\n")
        try cppSrc.write(to: cppURL, atomically: true, encoding: .utf8)
      }

      return changed
    }
    catch
    {
      log.error("error: failed to update source '\(fileURL.path)'. \(error.localizedDescription).")
      return false
    }
  }

  private func createTargetDirectories(packagePath: String, target: String) throws
  {
    // create target directory, if it doesn't exist.
    let targetDir = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)")
    if FileManager.default.fileExists(atPath: targetDir.path, isDirectory: nil) == false
    {
      try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
    }

    // create target include directory, if it doesn't exist.
    let targetIncDir = URL(fileURLWithPath: "\(packagePath)/Sources/\(target)/include/\(target)")
    if FileManager.default.fileExists(atPath: targetIncDir.path, isDirectory: nil) == false
    {
      try FileManager.default.createDirectory(at: targetIncDir, withIntermediateDirectories: true, attributes: nil)
    }
  }

  private func createPythonDirectories(packagePath: String, target: String) throws
  {
    // create python target directory, if it doesn't exist.
    let targetPyDir = URL(fileURLWithPath: "\(packagePath)/Python/Py\(target)")
    if FileManager.default.fileExists(atPath: targetPyDir.path, isDirectory: nil) == false
    {
      try FileManager.default.createDirectory(at: targetPyDir, withIntermediateDirectories: true, attributes: nil)
    }

    // create python target include directory, if it doesn't exist.
    let targetPyIncDir = URL(fileURLWithPath: "\(packagePath)/Python/Py\(target)/include/Py\(target)")
    if FileManager.default.fileExists(atPath: targetPyIncDir.path, isDirectory: nil) == false
    {
      try FileManager.default.createDirectory(at: targetPyIncDir, withIntermediateDirectories: true, attributes: nil)
    }
  }

  private func path(from enumerated: NSEnumerator.Element) -> String
  {
    enumerated as? String ?? ""
  }

  // Canonical casing for targets where .capitalized gets it wrong (e.g. UsdImagingGL -> Usdimaginggl).
  private static let targetCasing: [String: String] = [
    "camerautil": "CameraUtil",
    "esfusd": "EsfUsd",
    "execgeom": "ExecGeom",
    "execir": "ExecIr",
    "execusd": "ExecUsd",
    "geomutil": "GeomUtil",
    "hdar": "HdAr",
    "hdgp": "HdGp",
    "hdmtlx": "HdMtlx",
    "hdsi": "HdSi",
    "hdst": "HdSt",
    "hdstorm": "HdStorm",
    "hgigl": "HgiGL",
    "hgiinterop": "HgiInterop",
    "hgimetal": "HgiMetal",
    "hgivulkan": "HgiVulkan",
    "hioopenvdb": "HioOpenVDB",
    "pxosd": "PxOsd",
    "sdrglslfx": "SdrGlslfx",
    "sdrosl": "SdrOsl",
    "usdabc": "UsdAbc",
    "usdapputils": "UsdAppUtils",
    "usddraco": "UsdDraco",
    "usdexecimaging": "UsdExecImaging",
    "usdgeom": "UsdGeom",
    "usdhydra": "UsdHydra",
    "usdimaging": "UsdImaging",
    "usdimaginggl": "UsdImagingGL",
    "usdirimaging": "UsdIRImaging",
    "usdlod": "UsdLod",
    "usdlux": "UsdLux",
    "usdmedia": "UsdMedia",
    "usdmtlx": "UsdMtlx",
    "usdphysics": "UsdPhysics",
    "usdproc": "UsdProc",
    "usdprocimaging": "UsdProcImaging",
    "usdprofiles": "UsdProfiles",
    "usdrender": "UsdRender",
    "usdri": "UsdRi",
    "usdripxrimaging": "UsdRiPxrImaging",
    "usdsemantics": "UsdSemantics",
    "usdshade": "UsdShade",
    "usdshaders": "UsdShaders",
    "usdskel": "UsdSkel",
    "usdskelimaging": "UsdSkelImaging",
    "usdui": "UsdUI",
    "usdutils": "UsdUtils",
    "usdvalidation": "UsdValidation",
    "usdgeomvalidators": "UsdGeomValidators",
    "usdphysicsvalidators": "UsdPhysicsValidators",
    "usdshadevalidators": "UsdShadeValidators",
    "usdskelvalidators": "UsdSkelValidators",
    "usdutilsvalidators": "UsdUtilsValidators",
    "usdlodvalidators": "UsdLodValidators",
    "usdluxvalidators": "UsdLuxValidators",
    "usdviewq": "UsdViewQ",
    "usdvol": "UsdVol",
    "usdvolimaging": "UsdVolImaging",
  ]

  private func ensureCasing(for target: inout String)
  {
    if let canonical = Pxr.targetCasing[target.lowercased()]
    {
      target = canonical
    }
  }

  private enum Patch
  {
    /** Overrides upstream source wholesale with Resources/<target>/<key> if it exists. */
    public static func apply(to source: inout String, fileURL: URL, target: String, relativePath: String? = nil)
    {
      let key = relativePath ?? fileURL.lastPathComponent
      let resourceDir = (Bundle.module.resourceURL?.path ?? ".") + "/Resources/\(target)/\(key)"
      guard
        FileManager.default.fileExists(atPath: resourceDir),
        let patch = FileManager.default.contents(atPath: resourceDir)
      else { return }

      log.info("patching source: \(fileURL.path)")
      source = String(decoding: patch, as: UTF8.self)
    }

    /** Resolves @PLUG_INFO_*@ CMake placeholders (statically linked bundle; ResourcePath = "."). */
    public static func pluginfoTemplate(to source: inout String)
    {
      source = source.replacingOccurrences(of: "\"@PLUG_INFO_LIBRARY_PATH@\"", with: "\"\"")
      source = source.replacingOccurrences(of: "\"@PLUG_INFO_RESOURCE_PATH@\"", with: "\".\"")
      source = source.replacingOccurrences(of: "\"@PLUG_INFO_ROOT@\"", with: "\".\"")
    }

    /** Fixes plugInfo.json "Name" to use SwiftUSD capitalized target name (e.g. "usdGeom" -> "UsdGeom"). */
    public static func pluginfoName(to source: inout String, target: String)
    {
      let lower = target.prefix(1).lowercased() + target.dropFirst()
      source = source.replacingOccurrences(of: "\"Name\": \"\(lower)\"", with: "\"Name\": \"\(target)\"")
    }

    /** Patches schema.usda: fixes libraryName/libraryPath, pxr/ includes, and subLayer paths to SwiftUSD conventions. */
    public static func schemaUsda(to source: inout String, target: String)
    {
      let lower = target.prefix(1).lowercased() + target.dropFirst()

      // libraryName/libraryPath: strip pxr/ prefix, capitalize to match SwiftUSD target.
      source = source.replacingOccurrences(of: "= \"\(lower)\"",           with: "= \"\(target)\"")
      source = source.replacingOccurrences(of: "= \"pxr/base/\(lower)\"",  with: "= \"\(target)\"")
      source = source.replacingOccurrences(of: "= \"pxr/usd/\(lower)\"",   with: "= \"\(target)\"")

      // pxr/ includes embedded in customData C++ snippets -> SwiftUSD target paths.
      for (pxr, swift) in [
        ("pxr/base/gf/",      "Gf/"),
        ("pxr/base/tf/",      "Tf/"),
        ("pxr/usd/sdf/",      "Sdf/"),
        ("pxr/usd/sdr/",      "Sdr/"),
        ("pxr/usd/usd/",      "Usd/"),
        ("pxr/usd/usdGeom/",  "UsdGeom/"),
        ("pxr/usd/usdShade/", "UsdShade/"),
        ("pxr/usd/usdLux/",   "UsdLux/"),
        ("pxr/usd/usdSkel/",  "UsdSkel/"),
        ("pxr/usd/usdVol/",   "UsdVol/"),
        ("pxr/usd/usdPhysics/","UsdPhysics/"),
        ("pxr/usd/usdRender/","UsdRender/"),
        ("pxr/usd/usdRi/",    "UsdRi/"),
      ] {
        source = source.replacingOccurrences(of: "\"\(pxr)", with: "\"\(swift)")
      }

      // subLayer references: @usd/schema.usda@ -> @Usd/schema.usda@ etc.
      for (lower, upper) in [
        ("usd/schema.usda",     "Usd/schema.usda"),
        ("usdGeom/schema.usda", "UsdGeom/schema.usda"),
        ("usdShade/schema.usda","UsdShade/schema.usda"),
      ] {
        source = source.replacingOccurrences(of: "@\(lower)@", with: "@\(upper)@")
      }
    }

    /** Resolves @PXR_WORK_IMPL_HEADER@ in impl.h.in to Work/implTBB.h (matching enumerate()'s rename). */
    public static func configureTemplate(to source: inout String)
    {
      source = source.replacingOccurrences(of: "@PXR_WORK_IMPL_HEADER@", with: "\"Work/implTBB.h\"")
    }

    /** Collapses doubled directory segments from vendored-lib prefix capitalisation (e.g. Pegtl/pegtl/ -> Pegtl/). */
    public static func vendoredIncludes(to source: inout String, target: String)
    {
      source = source.replacingOccurrences(of: "Pegtl/pegtl/", with: "Pegtl/")
      source = source.replacingOccurrences(of: "Work/workTBB",  with: "Work")
    }

    /** Rewrites #include "<Target>/<target>.h" -> <target>Impl.h to avoid umbrella-name collisions. */
    public static func collidingUmbrellaInclude(to source: inout String, target: String)
    {
      let lower = target.lowercased()
      for (open, close) in [("\"", "\""), ("<", ">")]
      {
        source = source.replacingOccurrences(
          of: "#include \(open)\(target)/\(lower).h\(close)",
          with: "#include \(open)\(target)/\(lower)Impl.h\(close)"
        )
      }
    }

    /** crateDataTypes.h is an X-macro fragment; strip its pxrns.h import to avoid redundant-module-import inside enum body. */
    public static func xmacroFragmentHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "crateDataTypes.h" else { return }
      source = source.replacingOccurrences(of: "#include \"pxr/pxrns.h\"\n\n", with: "")
    }

    /** Hoists <limits.h>/<sys/param.h> above PXR_NAMESPACE_OPEN_SCOPE in fileSystem.h (modules forbid sys includes inside namespaces). */
    public static func fileSystemHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "fileSystem.h" else { return }
      source = source.replacingOccurrences(
        of: "PXR_NAMESPACE_OPEN_SCOPE\n\n/// \\addtogroup group_arch_SystemFunctions\n///@{\n#if !defined(ARCH_OS_WINDOWS)\n    #ifdef _POSIX_VERSION\n        #include <limits.h>                     /* for PATH_MAX */\n    #else\n        #include <sys/param.h>                  /* for MAXPATHLEN */\n    #endif\n#else",
        with: "#if !defined(ARCH_OS_WINDOWS)\n    #ifdef _POSIX_VERSION\n        #include <limits.h>                     /* for PATH_MAX */\n    #else\n        #include <sys/param.h>                  /* for MAXPATHLEN */\n    #endif\n#endif\n\nPXR_NAMESPACE_OPEN_SCOPE\n\n/// \\addtogroup group_arch_SystemFunctions\n///@{\n#if defined(ARCH_OS_WINDOWS)"
      )
    }

    public static func tfIteratorHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "iterator.h" else { return }
      source = source.replacingOccurrences(
        of: "    static_assert(std::is_same<iterator_category,\n                               std::random_access_iterator_tag>::value,\n                 \"Tf_ProxyReferenceReverseIterator must wrap a random \"\n                 \"access iterator.\");",
        with: ""
      )
      source = source.replacingOccurrences(
        of: "    static_assert(!std::is_reference<reference>::value,\n                 \"Tf_ProxyReferenceReverseIterator should only be used \"\n                 \"when the underlying iterator's reference type is a \"\n                 \"proxy (MyTypeRef) and not a true reference (MyType&).\"\n                 \"Use std::reverse_iterator instead.\");\n\n",
        with: ""
      )
    }

    /** Splits TfSmallVector::resize into two overloads to avoid the default-constructed
        value_type() argument that breaks non-default-constructible element types. */
    public static func tfSmallVectorHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "smallVector.h" else { return }
      source = source.replacingOccurrences(
        of: "    void resize(size_type newSize, const value_type &v = value_type()) {\n        // If the new size is smaller than the current size, let go of some\n        // entries at the tail.\n        if (newSize < size()) {\n            erase(const_iterator(data() + newSize), \n                  const_iterator(data() + size())); \n        }\n\n        // Otherwise, lets grow and fill: Reserve some storage, fill the tail\n        // end with copies of v, and update the new size.\n        else if (newSize > size()) {\n            reserve(newSize);\n            std::uninitialized_fill(data() + size(), data() + newSize, v);\n            _size = newSize;\n        }\n    }",
        with: "    void resize(size_type newSize) {\n        if (newSize < size()) {\n            erase(const_iterator(data() + newSize),\n                  const_iterator(data() + size()));\n        } else if (newSize > size()) {\n            reserve(newSize);\n            std::uninitialized_value_construct(data() + size(), data() + newSize);\n            _size = newSize;\n        }\n    }\n\n    void resize(size_type newSize, const value_type &v) {\n        if (newSize < size()) {\n            erase(const_iterator(data() + newSize),\n                  const_iterator(data() + size()));\n        } else if (newSize > size()) {\n            reserve(newSize);\n            std::uninitialized_fill(data() + size(), data() + newSize, v);\n            _size = newSize;\n        }\n    }"
      )
    }

    /** Annotates Hgi with SWIFT_SHARED_REFERENCE so Swift ARC can manage it via
        Tf_SharedPtrRetainReleaseHelper. Derived classes (HgiGL, HgiMetal, HgiVulkan) inherit
        the annotation automatically. */
    public static func hgi(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "hgiImpl.h" || fileBaseName == "hgi.cpp" || fileBaseName == "device.h"
              || fileBaseName == "texture.h"
      else { return }
      
      switch fileBaseName
      {
        case "hgiImpl.h":
          source = source.replacingOccurrences(
            of: "#include \"pxr/pxrns.h\"\n#include \"pxr/base/tf/token.h\"",
            with: "#include \"pxr/pxrns.h\"\n#include \"Arch/swiftInterop.h\"\n#include \"Tf/sharedPtrRetainReleaseHelper.h\"\n#include \"Tf/token.h\""
          )
          source = source.replacingOccurrences(
            of: "class Hgi\n{",
            with: "class SWIFT_SHARED_REFERENCE(HgiRetain, HgiRelease) Hgi\n{"
          )
          source = source.replacingOccurrences(
            of: "    static HgiUniquePtr CreatePlatformDefaultHgi();",
            with: "    static HgiUniquePtr CreatePlatformDefaultHgi();\n\n    /// Returns a raw Hgi* registered with Tf_SharedPtrRetainReleaseHelper for Swift ARC.\n    HGI_API SWIFT_RETURNS_RETAINED\n    static Hgi* CreatePlatformDefaultPtr();"
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            PXR_NAMESPACE_CLOSE_SCOPE

            inline void HgiRetain(Pixar::Hgi * _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Retain(x);
            }
            inline void HgiRelease(Pixar::Hgi * _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Release(x);
            }
            """
          )
        case "hgi.cpp":
          source = source.replacingOccurrences(
            of: "HgiUniquePtr\nHgi::CreatePlatformDefaultHgi()\n{\n    return HgiUniquePtr(_MakeNewPlatformDefaultHgi());\n}",
            with: """
            HgiUniquePtr
            Hgi::CreatePlatformDefaultHgi()
            {
                return HgiUniquePtr(_MakeNewPlatformDefaultHgi());
            }

            Hgi*
            Hgi::CreatePlatformDefaultPtr()
            {
                std::shared_ptr<Hgi> ptr(_MakeNewPlatformDefaultHgi());
                if (!ptr) { return nullptr; }
                return Tf_SharedPtrRetainReleaseHelper<Hgi>::Register(ptr);
            }
            """
          )
        case "device.h":
          // HgiGLDevice is owned by HgiGL and returned as a raw pointer.
          // SWIFT_UNSAFE_REFERENCE lets Swift import it as a reference type
          // without ARC - caller must not outlive the owning HgiGL instance.
          source = source.replacingOccurrences(
            of: "class HgiGLDevice final {",
            with: "class SWIFT_UNSAFE_REFERENCE HgiGLDevice final {"
          )
        case "texture.h":
          // HgiTexture is owned by Hgi's resource management; Swift holds it
          // only as a non-owning reference via HgiTextureHandle.Get().
          // HgiTextureHandle (= HgiHandle<HgiTexture>) imports as a Swift
          // value type (trivially-copyable pointer+id pair) automatically.
          source = source.replacingOccurrences(
            of: "#include \"pxr/imaging/hgi/types.h\"",
            with: "#include \"Hgi/types.h\"\n#include \"Arch/swiftInterop.h\""
          )
          source = source.replacingOccurrences(
            of: "class HgiTexture\n{",
            with: "class SWIFT_UNSAFE_REFERENCE HgiTexture\n{"
          )
        default:
          return
      }
    }
    
    public static func hgiMetal(to source: inout String, fileBaseName: String, target: String)
    {
      guard target == "HgiMetal" else { return }

      switch fileBaseName
      {
        case "texture.h":
          source = source.replacingOccurrences(
            of: "#include \"pxr/pxrns.h\"\n#include \"pxr/imaging/hgiMetal/api.h\"\n#include \"pxr/imaging/hgi/texture.h\"",
            with: "#include \"pxr/pxrns.h\"\n#include \"HgiMetal/api.h\"\n#include \"Hgi/texture.h\"\n#include \"Arch/swiftInterop.h\""
          )
          source = source.replacingOccurrences(
            of: "class HgiMetalTexture final : public HgiTexture {",
            with: "class SWIFT_UNSAFE_REFERENCE HgiMetalTexture final : public HgiTexture {"
          )

        case "hgi.h":
          source = source.replacingOccurrences(
            of: "class HgiMetal final : public Hgi\n{",
            with: "class SWIFT_SHARED_REFERENCE(HgiMetalRetain, HgiMetalRelease) HgiMetal final : public Hgi\n{"
          )
          source = source.replacingOccurrences(
            of: "class SWIFT_SHARED_REFERENCE(HgiMetalRetain, HgiMetalRelease) HgiMetal final : public Hgi\n{\npublic:",
            with: """
            class SWIFT_SHARED_REFERENCE(HgiMetalRetain, HgiMetalRelease) HgiMetal final : public Hgi
            {
            public:
                HGIMETAL_API SWIFT_RETURNS_RETAINED
                static HgiMetal* _Nonnull Create();
            """
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE\n\n#endif",
            with: """
            PXR_NAMESPACE_CLOSE_SCOPE

            inline void HgiMetalRetain(Pixar::HgiMetal* _Nonnull x)
            {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Retain(x);
            }

            inline void HgiMetalRelease(Pixar::HgiMetal* _Nonnull x)
            {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Release(x);
            }

            #endif
            """
          )

        case "hgi.mm":
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            /* static */
            HgiMetal*
            HgiMetal::Create()
            {
                std::shared_ptr<HgiMetal> ptr = std::make_shared<HgiMetal>();
                std::shared_ptr<Hgi> hgiPtr = ptr;
                return static_cast<HgiMetal*>(
                    Tf_SharedPtrRetainReleaseHelper<Hgi>::Register(hgiPtr));
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )

        default:
          return
      }
    }

    public static func hgiGL(to source: inout String, fileBaseName: String, target: String)
    {
      guard target == "HgiGL" else { return }

      switch fileBaseName
      {
        case "hgi.h":
          source = source.replacingOccurrences(
            of: "class HgiGL final : public Hgi\n{",
            with: "class SWIFT_SHARED_REFERENCE(HgiGLRetain, HgiGLRelease) HgiGL final : public Hgi\n{"
          )
          source = source.replacingOccurrences(
            of: "class SWIFT_SHARED_REFERENCE(HgiGLRetain, HgiGLRelease) HgiGL final : public Hgi\n{\npublic:",
            with: """
            class SWIFT_SHARED_REFERENCE(HgiGLRetain, HgiGLRelease) HgiGL final : public Hgi
            {
            public:
                HGIGL_API SWIFT_RETURNS_RETAINED
                static HgiGL* _Nonnull Create();
            """
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            PXR_NAMESPACE_CLOSE_SCOPE

            inline void HgiGLRetain(Pixar::HgiGL* _Nonnull x)
            {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Retain(x);
            }

            inline void HgiGLRelease(Pixar::HgiGL* _Nonnull x)
            {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::Hgi>::Release(x);
            }
            """
          )

        case "hgi.cpp":
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            /* static */
            HgiGL*
            HgiGL::Create()
            {
                std::shared_ptr<HgiGL> ptr = std::make_shared<HgiGL>();
                std::shared_ptr<Hgi> hgiPtr = ptr;
                return static_cast<HgiGL*>(
                    Tf_SharedPtrRetainReleaseHelper<Hgi>::Register(hgiPtr));
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )

        default:
          return
      }
    }

    public static func arResolver(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "resolver.h" else { return }
      // ArGetResolver() returns ArResolver& - the plugin registry owns the
      // resolver for process lifetime, so SWIFT_IMMORTAL_REFERENCE is correct.
      // ArDefaultResolver inherits the annotation through Swift C++ interop.
      source = source.replacingOccurrences(
        of: "#include \"pxr/usd/ar/api.h\"",
        with: "#include \"Arch/swiftInterop.h\"\n#include \"Ar/api.h\""
      )
      source = source.replacingOccurrences(
        of: "class ArResolver \n{",
        with: "class SWIFT_IMMORTAL_REFERENCE ArResolver \n{"
      )
    }

    public static func usdStageCacheContext(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "stageCacheContext.h" || fileBaseName == "stageCacheContext.cpp"
      else { return }

      switch fileBaseName
      {
        case "stageCacheContext.h":
          // Inject includes needed for SWIFT_SHARED_REFERENCE and retain/release helper.
          source = source.replacingOccurrences(
            of: "#include \"pxr/usd/usd/api.h\"\n#include \"pxr/base/tf/stacked.h\"",
            with: "#include \"Arch/swiftInterop.h\"\n#include \"Tf/sharedPtrRetainReleaseHelper.h\"\n#include \"Usd/api.h\"\n#include \"Tf/stacked.h\""
          )
          // Manually expand TF_DEFINE_STACKED to insert SWIFT_SHARED_REFERENCE on the
          // class declaration - the macro itself cannot carry the annotation.
          source = source.replacingOccurrences(
            of: "TF_DEFINE_STACKED(UsdStageCacheContext, true, USD_API)",
            with: """
            class UsdStageCacheContext;
            template <>
            struct Tf_ExportedStackedStorage<UsdStageCacheContext, true> {
                typedef typename Tf_StackedStorageType<UsdStageCacheContext, true>::Stack Stack;
                typedef typename Tf_StackedStorageType<UsdStageCacheContext, true>::Type Type;
                static USD_API std::atomic<Type*> value;
            };
            class SWIFT_SHARED_REFERENCE(UsdStageCacheContextRetain, UsdStageCacheContextRelease)
            UsdStageCacheContext :
                public TfStacked<UsdStageCacheContext, true,
                                 Tf_ExportedStackedStorage<UsdStageCacheContext, true>>
            """
          )
          // Add a heap-allocating factory that registers with the retain/release helper.
          source = source.replacingOccurrences(
            of: "    friend class UsdStage;",
            with: """
                public:
                /// Heap-allocates a context registered with Tf_SharedPtrRetainReleaseHelper
                /// so Swift ARC can manage it - destruction pops the thread-local cache stack.
                USD_API SWIFT_RETURNS_RETAINED
                static UsdStageCacheContext* _Nonnull Create(UsdStageCache& cache);

                private:
                friend class UsdStage;
            """
          )
          source = source.replacingOccurrences(
            of: "        UsdStageCache *_rwCache;\n        const UsdStageCache *_roCache;",
            with: "        UsdStageCache * _Nullable _rwCache;\n        const UsdStageCache * _Nullable _roCache;"
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            PXR_NAMESPACE_CLOSE_SCOPE

            inline void UsdStageCacheContextRetain(Pixar::UsdStageCacheContext* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::UsdStageCacheContext>::Retain(x);
            }
            inline void UsdStageCacheContextRelease(Pixar::UsdStageCacheContext* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::UsdStageCacheContext>::Release(x);
            }
            """
          )
        case "stageCacheContext.cpp":
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            /* static */
            UsdStageCacheContext*
            UsdStageCacheContext::Create(UsdStageCache& cache)
            {
                std::shared_ptr<UsdStageCacheContext> ptr =
                    std::make_shared<UsdStageCacheContext>(cache);
                return Tf_SharedPtrRetainReleaseHelper<UsdStageCacheContext>::Register(ptr);
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )
        default:
          return
      }
    }

    public static func usdImagingGL(to source: inout String, fileBaseName: String, target: String)
    {
      guard fileBaseName == "engine.h" || fileBaseName == "engine.cpp",
            target == "UsdImagingGL"
      else { return }

      switch fileBaseName
      {
        case "engine.h":
          // engine.h already gets swiftInterop.h + sharedPtrRetainReleaseHelper.h
          // transitively through Hgi/hgiImpl.h - no extra includes needed.
          source = source.replacingOccurrences(
            of: "class UsdImagingGLEngine\n{",
            with: "class SWIFT_SHARED_REFERENCE(UsdImagingGLEngineRetain, UsdImagingGLEngineRelease) UsdImagingGLEngine\n{"
          )
          // HgiHandle<T> templates are not importable by Swift when T is
          // SWIFT_UNSAFE_REFERENCE; add a concrete overlay returning T* directly.
          source = source.replacingOccurrences(
            of: "    HgiTextureHandle GetAovTexture(TfToken const& name) const;",
            with: """
                HgiTextureHandle GetAovTexture(TfToken const& name) const;

                /// Swift-importable variant - returns the raw non-owning HgiTexture pointer.
                /// HgiHandle<T> templates are not importable by Swift; use this instead.
                HgiTexture* _Nullable GetAovTexturePtr(TfToken const& name) const {
                    return GetAovTexture(name).Get();
                }
            """
          )
          source = source.replacingOccurrences(
            of: "    USDIMAGINGGL_API\n    UsdImagingGLEngine(const Parameters &params);",
            with: """
                /// Creates a heap-allocated engine registered with Tf_SharedPtrRetainReleaseHelper
                /// for Swift ARC lifetime management.
                USDIMAGINGGL_API SWIFT_RETURNS_RETAINED
                static UsdImagingGLEngine* _Nonnull Create(const SdfPath& rootPath,
                                                           const SdfPathVector& excludedPaths,
                                                           const SdfPathVector& invisedPaths,
                                                           const SdfPath& sceneDelegateID,
                                                           const HdDriver& driver,
                                                           const TfToken& rendererPluginId,
                                                           const bool gpuEnabled,
                                                           const bool displayUnloadedPrimsWithBounds,
                                                           const bool allowAsynchronousSceneProcessing,
                                                           const bool enableUsdDrawModes);

                USDIMAGINGGL_API
                UsdImagingGLEngine(const Parameters &params);
            """
          )
          source = source.replacingOccurrences(
            of: "    bool _enableUsdDrawModes = true;\n};\n\nPXR_NAMESPACE_CLOSE_SCOPE",
            with: """
                bool _enableUsdDrawModes = true;
            };

            PXR_NAMESPACE_CLOSE_SCOPE

            inline void UsdImagingGLEngineRetain(Pixar::UsdImagingGLEngine* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::UsdImagingGLEngine>::Retain(x);
            }
            inline void UsdImagingGLEngineRelease(Pixar::UsdImagingGLEngine* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::UsdImagingGLEngine>::Release(x);
            }
            """
          )
        case "engine.cpp":
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            /* static */
            UsdImagingGLEngine*
            UsdImagingGLEngine::Create(const SdfPath& rootPath,
                                       const SdfPathVector& excludedPaths,
                                       const SdfPathVector& invisedPaths,
                                       const SdfPath& sceneDelegateID,
                                       const HdDriver& driver,
                                       const TfToken& rendererPluginId,
                                       const bool gpuEnabled,
                                       const bool displayUnloadedPrimsWithBounds,
                                       const bool allowAsynchronousSceneProcessing,
                                       const bool enableUsdDrawModes)
            {
              std::shared_ptr<UsdImagingGLEngine> engine = std::make_shared<UsdImagingGLEngine>();

              engine.reset(new UsdImagingGLEngine(
                rootPath,
                excludedPaths,
                invisedPaths,
                sceneDelegateID,
                driver,
                rendererPluginId,
                gpuEnabled,
                displayUnloadedPrimsWithBounds,
                allowAsynchronousSceneProcessing,
                enableUsdDrawModes
              ));

              return Tf_SharedPtrRetainReleaseHelper<UsdImagingGLEngine>::Register(engine);
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )
        default:
          return
      }
    }

    public static func execUsd(to source: inout String, fileBaseName: String, target: String)
    {
      guard target == "ExecUsd",
            fileBaseName == "system.h" || fileBaseName == "system.cpp" || fileBaseName == "valueKey.h"
      else { return }

      switch fileBaseName
      {
        case "system.h":
          // ExecUsdSystem is the concrete type Swift holds. SWIFT_SHARED_REFERENCE
          // registers it with Tf_SharedPtrRetainReleaseHelper so Swift ARC can manage
          // its lifetime, mirroring the HgiGL/HgiMetal/UsdImagingGLEngine pattern
          // (Create() factory here, Register() call in system.cpp, retain/release
          // hooks below the namespace).
          source = source.replacingOccurrences(
            of: "#include \"pxr/exec/exec/system.h\"",
            with: "#include \"pxr/exec/exec/system.h\"\n#include \"pxr/base/arch/swiftInterop.h\"\n#include \"pxr/base/tf/sharedPtrRetainReleaseHelper.h\""
          )
          source = source.replacingOccurrences(
            of: "class ExecUsdSystem : public ExecSystem\n{",
            with: "class SWIFT_SHARED_REFERENCE(ExecUsdSystemRetain, ExecUsdSystemRelease) ExecUsdSystem : public ExecSystem\n{"
          )
          source = source.replacingOccurrences(
            of: "public:\n    EXECUSD_API\n    explicit ExecUsdSystem(const UsdStageConstRefPtr &stage);",
            with: """
            public:
                /// Heap-allocates a system registered with Tf_SharedPtrRetainReleaseHelper
                /// for Swift ARC lifetime management.
                EXECUSD_API SWIFT_RETURNS_RETAINED
                static ExecUsdSystem* _Nonnull Create(const UsdStageRefPtr &stage);

                EXECUSD_API
                explicit ExecUsdSystem(const UsdStageConstRefPtr &stage);
            """
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            PXR_NAMESPACE_CLOSE_SCOPE

            inline void ExecUsdSystemRetain(Pixar::ExecUsdSystem* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::ExecUsdSystem>::Retain(x);
            }
            inline void ExecUsdSystemRelease(Pixar::ExecUsdSystem* _Nonnull x) {
                Pixar::Tf_SharedPtrRetainReleaseHelper<Pixar::ExecUsdSystem>::Release(x);
            }
            """
          )

        case "system.cpp":
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            /* static */
            ExecUsdSystem*
            ExecUsdSystem::Create(const UsdStageRefPtr &stage)
            {
                std::shared_ptr<ExecUsdSystem> ptr = std::make_shared<ExecUsdSystem>(stage);
                return Tf_SharedPtrRetainReleaseHelper<ExecUsdSystem>::Register(ptr);
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )

        case "valueKey.h":
          // ExecUsdSystemWrapper's Swift-facing APIs pass value keys around as a
          // vector; expose the vector alias alongside the class itself.
          source = source.replacingOccurrences(
            of: "#include <variant>",
            with: "#include <variant>\n#include <vector>"
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: "\n\ntypedef std::vector<ExecUsdValueKey> ExecUsdValueKeyVec;\n\nPXR_NAMESPACE_CLOSE_SCOPE"
          )

        default:
          return
      }
    }

    public static func sdfTypes(to source: inout String, fileBaseName: String, target: String)
    {
      guard (fileBaseName == "types.h" || fileBaseName == "valueTypeName.cpp"),
            target == "Sdf"
      else { return }

      switch fileBaseName
      {
        case "types.h":
          source = source.replacingOccurrences(
            of: "extern SDF_API TfStaticData<const Sdf_ValueTypeNamesType,\n    Sdf_ValueTypeNamesType::_Init> SdfValueTypeNames;",
            with: """
            extern SDF_API TfStaticData<const Sdf_ValueTypeNamesType,
                Sdf_ValueTypeNamesType::_Init> SdfValueTypeNames;

            /// Swift-importable enum of all SdfValueTypeName cases.
            /// Enumerators carry the SdfValueTypeNameType prefix so Swift's C++ interop
            /// strips it and imports them as .bool, .uChar, .float3Array, etc.
            /// Pass a value to SdfGetValueTypeName() to retrieve the corresponding
            /// SdfValueTypeName for use with USD APIs.
            enum class SdfValueTypeNameType {
                SdfValueTypeNameTypeBool = 0,
                SdfValueTypeNameTypeUChar, SdfValueTypeNameTypeInt, SdfValueTypeNameTypeUInt,
                SdfValueTypeNameTypeInt64, SdfValueTypeNameTypeUInt64,
                SdfValueTypeNameTypeHalf, SdfValueTypeNameTypeFloat, SdfValueTypeNameTypeDouble,
                SdfValueTypeNameTypeTimeCode,
                SdfValueTypeNameTypeString, SdfValueTypeNameTypeToken, SdfValueTypeNameTypeAsset,
                SdfValueTypeNameTypeInt2, SdfValueTypeNameTypeInt3, SdfValueTypeNameTypeInt4,
                SdfValueTypeNameTypeHalf2, SdfValueTypeNameTypeHalf3, SdfValueTypeNameTypeHalf4,
                SdfValueTypeNameTypeFloat2, SdfValueTypeNameTypeFloat3, SdfValueTypeNameTypeFloat4,
                SdfValueTypeNameTypeDouble2, SdfValueTypeNameTypeDouble3, SdfValueTypeNameTypeDouble4,
                SdfValueTypeNameTypePoint3h, SdfValueTypeNameTypePoint3f, SdfValueTypeNameTypePoint3d,
                SdfValueTypeNameTypeVector3h, SdfValueTypeNameTypeVector3f, SdfValueTypeNameTypeVector3d,
                SdfValueTypeNameTypeNormal3h, SdfValueTypeNameTypeNormal3f, SdfValueTypeNameTypeNormal3d,
                SdfValueTypeNameTypeColor3h, SdfValueTypeNameTypeColor3f, SdfValueTypeNameTypeColor3d,
                SdfValueTypeNameTypeColor4h, SdfValueTypeNameTypeColor4f, SdfValueTypeNameTypeColor4d,
                SdfValueTypeNameTypeQuath, SdfValueTypeNameTypeQuatf, SdfValueTypeNameTypeQuatd,
                SdfValueTypeNameTypeMatrix2d, SdfValueTypeNameTypeMatrix3d, SdfValueTypeNameTypeMatrix4d,
                SdfValueTypeNameTypeFrame4d,
                SdfValueTypeNameTypeTexCoord2h, SdfValueTypeNameTypeTexCoord2f, SdfValueTypeNameTypeTexCoord2d,
                SdfValueTypeNameTypeTexCoord3h, SdfValueTypeNameTypeTexCoord3f, SdfValueTypeNameTypeTexCoord3d,
                SdfValueTypeNameTypeOpaque,
                SdfValueTypeNameTypeGroup,
                SdfValueTypeNameTypePathExpression,
                SdfValueTypeNameTypeBoolArray,
                SdfValueTypeNameTypeUCharArray, SdfValueTypeNameTypeIntArray, SdfValueTypeNameTypeUIntArray,
                SdfValueTypeNameTypeInt64Array, SdfValueTypeNameTypeUInt64Array,
                SdfValueTypeNameTypeHalfArray, SdfValueTypeNameTypeFloatArray, SdfValueTypeNameTypeDoubleArray,
                SdfValueTypeNameTypeTimeCodeArray,
                SdfValueTypeNameTypeStringArray, SdfValueTypeNameTypeTokenArray, SdfValueTypeNameTypeAssetArray,
                SdfValueTypeNameTypeInt2Array, SdfValueTypeNameTypeInt3Array, SdfValueTypeNameTypeInt4Array,
                SdfValueTypeNameTypeHalf2Array, SdfValueTypeNameTypeHalf3Array, SdfValueTypeNameTypeHalf4Array,
                SdfValueTypeNameTypeFloat2Array, SdfValueTypeNameTypeFloat3Array, SdfValueTypeNameTypeFloat4Array,
                SdfValueTypeNameTypeDouble2Array, SdfValueTypeNameTypeDouble3Array, SdfValueTypeNameTypeDouble4Array,
                SdfValueTypeNameTypePoint3hArray, SdfValueTypeNameTypePoint3fArray, SdfValueTypeNameTypePoint3dArray,
                SdfValueTypeNameTypeVector3hArray, SdfValueTypeNameTypeVector3fArray, SdfValueTypeNameTypeVector3dArray,
                SdfValueTypeNameTypeNormal3hArray, SdfValueTypeNameTypeNormal3fArray, SdfValueTypeNameTypeNormal3dArray,
                SdfValueTypeNameTypeColor3hArray, SdfValueTypeNameTypeColor3fArray, SdfValueTypeNameTypeColor3dArray,
                SdfValueTypeNameTypeColor4hArray, SdfValueTypeNameTypeColor4fArray, SdfValueTypeNameTypeColor4dArray,
                SdfValueTypeNameTypeQuathArray, SdfValueTypeNameTypeQuatfArray, SdfValueTypeNameTypeQuatdArray,
                SdfValueTypeNameTypeMatrix2dArray, SdfValueTypeNameTypeMatrix3dArray, SdfValueTypeNameTypeMatrix4dArray,
                SdfValueTypeNameTypeFrame4dArray,
                SdfValueTypeNameTypeTexCoord2hArray, SdfValueTypeNameTypeTexCoord2fArray, SdfValueTypeNameTypeTexCoord2dArray,
                SdfValueTypeNameTypeTexCoord3hArray, SdfValueTypeNameTypeTexCoord3fArray, SdfValueTypeNameTypeTexCoord3dArray,
                SdfValueTypeNameTypePathExpressionArray,
            };

            SDF_API const SdfValueTypeName& SdfGetValueTypeName(SdfValueTypeNameType type);
            """
          )
        case "valueTypeName.cpp":
          source = source.replacingOccurrences(
            of: "#include \"Sdf/valueTypeName.h\"",
            with: "#include \"Sdf/valueTypeName.h\"\n#include \"Sdf/types.h\""
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE",
            with: """
            const SdfValueTypeName&
            SdfGetValueTypeName(SdfValueTypeNameType type)
            {
                switch (type) {
                    case SdfValueTypeNameType::SdfValueTypeNameTypeBool:             return SdfValueTypeNames->Bool;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUChar:            return SdfValueTypeNames->UChar;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt:              return SdfValueTypeNames->Int;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUInt:             return SdfValueTypeNames->UInt;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt64:            return SdfValueTypeNames->Int64;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUInt64:           return SdfValueTypeNames->UInt64;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf:             return SdfValueTypeNames->Half;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat:            return SdfValueTypeNames->Float;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble:           return SdfValueTypeNames->Double;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTimeCode:         return SdfValueTypeNames->TimeCode;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeString:           return SdfValueTypeNames->String;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeToken:            return SdfValueTypeNames->Token;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeAsset:            return SdfValueTypeNames->Asset;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt2:             return SdfValueTypeNames->Int2;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt3:             return SdfValueTypeNames->Int3;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt4:             return SdfValueTypeNames->Int4;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf2:            return SdfValueTypeNames->Half2;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf3:            return SdfValueTypeNames->Half3;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf4:            return SdfValueTypeNames->Half4;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat2:           return SdfValueTypeNames->Float2;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat3:           return SdfValueTypeNames->Float3;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat4:           return SdfValueTypeNames->Float4;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble2:          return SdfValueTypeNames->Double2;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble3:          return SdfValueTypeNames->Double3;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble4:          return SdfValueTypeNames->Double4;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3h:          return SdfValueTypeNames->Point3h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3f:          return SdfValueTypeNames->Point3f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3d:          return SdfValueTypeNames->Point3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3h:         return SdfValueTypeNames->Vector3h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3f:         return SdfValueTypeNames->Vector3f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3d:         return SdfValueTypeNames->Vector3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3h:         return SdfValueTypeNames->Normal3h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3f:         return SdfValueTypeNames->Normal3f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3d:         return SdfValueTypeNames->Normal3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3h:          return SdfValueTypeNames->Color3h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3f:          return SdfValueTypeNames->Color3f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3d:          return SdfValueTypeNames->Color3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4h:          return SdfValueTypeNames->Color4h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4f:          return SdfValueTypeNames->Color4f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4d:          return SdfValueTypeNames->Color4d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuath:            return SdfValueTypeNames->Quath;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuatf:            return SdfValueTypeNames->Quatf;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuatd:            return SdfValueTypeNames->Quatd;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix2d:         return SdfValueTypeNames->Matrix2d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix3d:         return SdfValueTypeNames->Matrix3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix4d:         return SdfValueTypeNames->Matrix4d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFrame4d:          return SdfValueTypeNames->Frame4d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2h:       return SdfValueTypeNames->TexCoord2h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2f:       return SdfValueTypeNames->TexCoord2f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2d:       return SdfValueTypeNames->TexCoord2d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3h:       return SdfValueTypeNames->TexCoord3h;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3f:       return SdfValueTypeNames->TexCoord3f;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3d:       return SdfValueTypeNames->TexCoord3d;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeOpaque:           return SdfValueTypeNames->Opaque;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeGroup:            return SdfValueTypeNames->Group;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePathExpression:   return SdfValueTypeNames->PathExpression;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeBoolArray:        return SdfValueTypeNames->BoolArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUCharArray:       return SdfValueTypeNames->UCharArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeIntArray:         return SdfValueTypeNames->IntArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUIntArray:        return SdfValueTypeNames->UIntArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt64Array:       return SdfValueTypeNames->Int64Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeUInt64Array:      return SdfValueTypeNames->UInt64Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalfArray:        return SdfValueTypeNames->HalfArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloatArray:       return SdfValueTypeNames->FloatArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDoubleArray:      return SdfValueTypeNames->DoubleArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTimeCodeArray:    return SdfValueTypeNames->TimeCodeArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeStringArray:      return SdfValueTypeNames->StringArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTokenArray:       return SdfValueTypeNames->TokenArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeAssetArray:       return SdfValueTypeNames->AssetArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt2Array:        return SdfValueTypeNames->Int2Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt3Array:        return SdfValueTypeNames->Int3Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeInt4Array:        return SdfValueTypeNames->Int4Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf2Array:       return SdfValueTypeNames->Half2Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf3Array:       return SdfValueTypeNames->Half3Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeHalf4Array:       return SdfValueTypeNames->Half4Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat2Array:      return SdfValueTypeNames->Float2Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat3Array:      return SdfValueTypeNames->Float3Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFloat4Array:      return SdfValueTypeNames->Float4Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble2Array:     return SdfValueTypeNames->Double2Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble3Array:     return SdfValueTypeNames->Double3Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeDouble4Array:     return SdfValueTypeNames->Double4Array;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3hArray:     return SdfValueTypeNames->Point3hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3fArray:     return SdfValueTypeNames->Point3fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePoint3dArray:     return SdfValueTypeNames->Point3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3hArray:    return SdfValueTypeNames->Vector3hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3fArray:    return SdfValueTypeNames->Vector3fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeVector3dArray:    return SdfValueTypeNames->Vector3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3hArray:    return SdfValueTypeNames->Normal3hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3fArray:    return SdfValueTypeNames->Normal3fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeNormal3dArray:    return SdfValueTypeNames->Normal3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3hArray:     return SdfValueTypeNames->Color3hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3fArray:     return SdfValueTypeNames->Color3fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor3dArray:     return SdfValueTypeNames->Color3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4hArray:     return SdfValueTypeNames->Color4hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4fArray:     return SdfValueTypeNames->Color4fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeColor4dArray:     return SdfValueTypeNames->Color4dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuathArray:       return SdfValueTypeNames->QuathArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuatfArray:       return SdfValueTypeNames->QuatfArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeQuatdArray:       return SdfValueTypeNames->QuatdArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix2dArray:    return SdfValueTypeNames->Matrix2dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix3dArray:    return SdfValueTypeNames->Matrix3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeMatrix4dArray:    return SdfValueTypeNames->Matrix4dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeFrame4dArray:     return SdfValueTypeNames->Frame4dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2hArray:  return SdfValueTypeNames->TexCoord2hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2fArray:  return SdfValueTypeNames->TexCoord2fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord2dArray:  return SdfValueTypeNames->TexCoord2dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3hArray:  return SdfValueTypeNames->TexCoord3hArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3fArray:  return SdfValueTypeNames->TexCoord3fArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypeTexCoord3dArray:  return SdfValueTypeNames->TexCoord3dArray;
                    case SdfValueTypeNameType::SdfValueTypeNameTypePathExpressionArray: return SdfValueTypeNames->PathExpressionArray;
                }
            }

            PXR_NAMESPACE_CLOSE_SCOPE
            """
          )
        default:
          return
      }
    }

    /** Moves #includes that appear after PXR_NAMESPACE_OPEN_SCOPE in backPlateAPI.cpp to before it. */
    public static func backPlateAPI(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "backPlateAPI.cpp" else { return }
      source = source.replacingOccurrences(
        of: "PXR_NAMESPACE_OPEN_SCOPE\n#include <cmath>\n#include \"pxr/base/gf/camera.h\"\n#include \"pxr/base/gf/vec3f.h\"\n#include \"pxr/base/gf/vec2f.h\"",
        with: "#include <cmath>\n#include \"pxr/base/gf/camera.h\"\n#include \"pxr/base/gf/vec3f.h\"\n#include \"pxr/base/gf/vec2f.h\"\n\nPXR_NAMESPACE_OPEN_SCOPE"
      )
    }

    public static func usdCommon(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "common.h" else { return }

      // Convert plain C enum to scoped enum class. Enumerators keep the full
      // UsdListPosition prefix so Swift's C++ interop strips it and imports them
      // as .frontOfPrependList, .backOfPrependList, etc.
      // Backward-compat constexpr aliases keep all existing C++ callers compiling unchanged.
      source = source.replacingOccurrences(
        of: #"enum\s+UsdListPosition\s*\{[\s\S]*?\};"#,
        with: """
        enum class UsdListPosition {
            /// The position at the front of the prepend list.
            /// An item added at this position will, after composition is applied,
            /// be stronger than other items prepended in this layer, and stronger
            /// than items added by weaker layers.
            UsdListPositionFrontOfPrependList,
            /// The position at the back of the prepend list.
            /// An item added at this position will, after composition is applied,
            /// be weaker than other items prepended in this layer, but stronger
            /// than items added by weaker layers.
            UsdListPositionBackOfPrependList,
            /// The position at the front of the append list.
            /// An item added at this position will, after composition is applied,
            /// be stronger than other items appended in this layer, and stronger
            /// than items added by weaker layers.
            UsdListPositionFrontOfAppendList,
            /// The position at the back of the append list.
            /// An item added at this position will, after composition is applied,
            /// be weaker than other items appended in this layer, but stronger
            /// than items added by weaker layers.
            UsdListPositionBackOfAppendList,
        };

        // Backward-compat aliases - all existing C++ callers compile unchanged.
        constexpr UsdListPosition UsdListPositionFrontOfPrependList = UsdListPosition::UsdListPositionFrontOfPrependList;
        constexpr UsdListPosition UsdListPositionBackOfPrependList  = UsdListPosition::UsdListPositionBackOfPrependList;
        constexpr UsdListPosition UsdListPositionFrontOfAppendList  = UsdListPosition::UsdListPositionFrontOfAppendList;
        constexpr UsdListPosition UsdListPositionBackOfAppendList   = UsdListPosition::UsdListPositionBackOfAppendList;
        """,
        options: .regularExpression
      )

      source = source.replacingOccurrences(
        of: #"enum\s+UsdLoadPolicy\s*\{[\s\S]*?\};"#,
        with: """
        enum class UsdLoadPolicy {
            /// Load a prim plus all its descendants.
            UsdLoadPolicyWithDescendants,
            /// Load a prim by itself with no descendants.
            UsdLoadPolicyWithoutDescendants
        };

        // Backward-compat aliases - all existing C++ callers compile unchanged.
        constexpr UsdLoadPolicy UsdLoadWithDescendants    = UsdLoadPolicy::UsdLoadPolicyWithDescendants;
        constexpr UsdLoadPolicy UsdLoadWithoutDescendants = UsdLoadPolicy::UsdLoadPolicyWithoutDescendants;
        """,
        options: .regularExpression
      )

      // UsdSchemaKind is already enum class - add prefixed members for Swift interop
      // alongside duplicate same-value aliases that keep UsdSchemaKind::Invalid etc. working.
      source = source.replacingOccurrences(
        of: #"enum(?:\s+class)?\s+UsdSchemaKind\s*\{[^}]*\};"#,
        with: """
        enum class UsdSchemaKind {
            /// Invalid or unknown schema kind.
            UsdSchemaKindInvalid,
            /// Represents abstract or base schema types that are interface-only
            /// and cannot be instantiated. These are reserved for core base classes
            /// known to the usdGenSchema system, so this should never be assigned to
            /// generated schema classes.
            UsdSchemaKindAbstractBase,
            /// Represents a non-concrete typed schema
            UsdSchemaKindAbstractTyped,
            /// Represents a concrete typed schema
            UsdSchemaKindConcreteTyped,
            /// Non-applied API schema
            UsdSchemaKindNonAppliedAPI,
            /// Single Apply API schema
            UsdSchemaKindSingleApplyAPI,
            /// Multiple Apply API Schema
            UsdSchemaKindMultipleApplyAPI,
            // Backward-compat aliases - all existing UsdSchemaKind::Xxx callers compile unchanged.
            Invalid          = UsdSchemaKindInvalid,
            AbstractBase     = UsdSchemaKindAbstractBase,
            AbstractTyped    = UsdSchemaKindAbstractTyped,
            ConcreteTyped    = UsdSchemaKindConcreteTyped,
            NonAppliedAPI    = UsdSchemaKindNonAppliedAPI,
            SingleApplyAPI   = UsdSchemaKindSingleApplyAPI,
            MultipleApplyAPI = UsdSchemaKindMultipleApplyAPI,
        };
        """,
        options: .regularExpression
      )
    }
    
    public static func xformOp(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "xformOp.h" else { return }

      source = source.replacingOccurrences(
        of: #"enum\s+Type\s*\{[\s\S]*?\};"#,
        with: #"""
        enum class Type {
                TypeInvalid,   ///< Represents an invalid xformOp.
                TypeTranslateX,///< Translation along the X-axis.
                TypeTranslateY,///< Translation along the Y-axis.
                TypeTranslateZ,///< Translation along the Z-axis.
                TypeTranslate, ///< XYZ translation.
                TypeScaleX,    ///< Scale along the X-axis.
                TypeScaleY,    ///< Scale along the Y-axis.
                TypeScaleZ,    ///< Scale along the Z-axis.
                TypeScale,     ///< XYZ scale.
                TypeRotateX,   ///< Rotation about the X-axis, <b>in degrees</b>.
                TypeRotateY,   ///< Rotation about the Y-axis, <b>in degrees</b>.
                TypeRotateZ,   ///< Rotation about the Z-axis, <b>in degrees</b>.
                TypeRotateXYZ, ///< Set of 3 canonical Euler rotations
                               ///  \ref usdGeom_rotationPackingOrder "in XYZ order"
                TypeRotateXZY, ///< Set of 3 canonical Euler rotations 
                               /// \ref usdGeom_rotationPackingOrder "in XZY order"
                TypeRotateYXZ, ///< Set of 3 canonical Euler rotations 
                               /// \ref usdGeom_rotationPackingOrder "in YXZ order"
                TypeRotateYZX, ///< Set of 3 canonical Euler rotations 
                               /// \ref usdGeom_rotationPackingOrder "in YZX order"
                TypeRotateZXY, ///< Set of 3 canonical Euler rotations 
                               /// \ref usdGeom_rotationPackingOrder "in ZXY order"
                TypeRotateZYX, ///< Set of 3 canonical Euler rotations 
                               /// \ref usdGeom_rotationPackingOrder "in ZYX order"
                TypeOrient,    ///< Arbitrary axis/angle rotation, expressed as a quaternion.
                TypeTransform  ///< A 4x4 matrix transformation.
            };
        
            static constexpr Type TypeInvalid = Type::TypeInvalid;
            static constexpr Type TypeTranslateX = Type::TypeTranslateX;
            static constexpr Type TypeTranslateY = Type::TypeTranslateY;
            static constexpr Type TypeTranslateZ = Type::TypeTranslateZ;
            static constexpr Type TypeTranslate = Type::TypeTranslate;
            static constexpr Type TypeScaleX = Type::TypeScaleX;
            static constexpr Type TypeScaleY = Type::TypeScaleY;
            static constexpr Type TypeScaleZ = Type::TypeScaleZ;
            static constexpr Type TypeScale = Type::TypeScale;
            static constexpr Type TypeRotateX = Type::TypeRotateX;
            static constexpr Type TypeRotateY = Type::TypeRotateY;
            static constexpr Type TypeRotateZ = Type::TypeRotateZ;
            static constexpr Type TypeRotateXYZ = Type::TypeRotateXYZ;
            static constexpr Type TypeRotateXZY = Type::TypeRotateXZY; 
            static constexpr Type TypeRotateYXZ = Type::TypeRotateYXZ; 
            static constexpr Type TypeRotateYZX = Type::TypeRotateYZX; 
            static constexpr Type TypeRotateZXY = Type::TypeRotateZXY; 
            static constexpr Type TypeRotateZYX = Type::TypeRotateZYX;
            static constexpr Type TypeOrient = Type::TypeOrient;
            static constexpr Type TypeTransform = Type::TypeTransform;
        """#,
        options: .regularExpression
      )
      source = source.replacingOccurrences(
        of: #"enum\s+Precision\s*\{[\s\S]*?\};"#,
        with: #"""
        enum class Precision {
                PrecisionDouble, ///< Double precision
                PrecisionFloat,  ///< Floating-point precision 
                PrecisionHalf    ///< Half-float precision
            };
        
            static constexpr Precision PrecisionDouble = Precision::PrecisionDouble;
            static constexpr Precision PrecisionFloat = Precision::PrecisionFloat;
            static constexpr Precision PrecisionHalf = Precision::PrecisionHalf;
        """#,
        options: .regularExpression
      )
    }

    public static func xformCommonAPI(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "xformCommonAPI.cpp" else { return }

      // enum class Type doesn't support arithmetic or relational operators -
      // cast to int for the static_assert subtractions and range comparisons.
      source = source.replacingOccurrences(
        of: """
            static_assert(
                UsdGeomXformOp::TypeRotateZYX - UsdGeomXformOp::TypeRotateXYZ == 5,
                "Exactly six three-axis rotate op types");
            return opType >= UsdGeomXformOp::TypeRotateXYZ &&
                   opType <= UsdGeomXformOp::TypeRotateZYX;
        """,
        with: """
            static_assert(
                static_cast<int>(UsdGeomXformOp::TypeRotateZYX) - static_cast<int>(UsdGeomXformOp::TypeRotateXYZ) == 5,
                "Exactly six three-axis rotate op types");
            return static_cast<int>(opType) >= static_cast<int>(UsdGeomXformOp::TypeRotateXYZ) &&
                   static_cast<int>(opType) <= static_cast<int>(UsdGeomXformOp::TypeRotateZYX);
        """
      )

      source = source.replacingOccurrences(
        of: """
            static_assert(
                UsdGeomXformOp::TypeRotateZYX - UsdGeomXformOp::TypeRotateX == 8,
                "Exactly nine rotate op types");
            return opType >= UsdGeomXformOp::TypeRotateX &&
                   opType <= UsdGeomXformOp::TypeRotateZYX;
        """,
        with: """
            static_assert(
                static_cast<int>(UsdGeomXformOp::TypeRotateZYX) - static_cast<int>(UsdGeomXformOp::TypeRotateX) == 8,
                "Exactly nine rotate op types");
            return static_cast<int>(opType) >= static_cast<int>(UsdGeomXformOp::TypeRotateX) &&
                   static_cast<int>(opType) <= static_cast<int>(UsdGeomXformOp::TypeRotateZYX);
        """
      )
    }

    public static func plugRegistry(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "registry.h" else { return }

      source = source.replacingOccurrences(
        of: "#include \"pxr/pxrns.h\"\n#include \"pxr/base/plug/api.h\"",
        with: "#include \"pxr/pxrns.h\"\n#include \"Plug/api.h\"\n#include \"Arch/swiftInterop.h\""
      )
      source = source.replacingOccurrences(
        of: "class PlugRegistry : public TfWeakBase {",
        with: "class SWIFT_IMMORTAL_REFERENCE PlugRegistry : public TfWeakBase {"
      )
    }

    public static func tfRefBaseHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "refBase.h" else { return }
      source = source.replacingOccurrences(
        of: "#include \"pxr/base/tf/api.h\"",
        with: "#include \"Arch/swiftInterop.h\"\n#include \"Tf/api.h\""
      )
      source = source.replacingOccurrences(
        of: "class TfRefBase {",
        with: "class SWIFT_SHARED_REFERENCE(__retain__ZN3Pixar9TfRefBaseE, __release__ZN3Pixar9TfRefBaseE) TfRefBase {"
      )
      source = source.replacingOccurrences(
        of: "typedef void (*UniqueChangedFuncPtr)(TfRefBase const *, bool);",
        with: "typedef void (*UniqueChangedFuncPtr)(TfRefBase const * _Nonnull, bool);"
      )
      source = source.replacingOccurrences(
        of: "        void (*lock)();\n        UniqueChangedFuncPtr func;\n        void (*unlock)();",
        with: "        void (* _Nonnull lock)();\n        UniqueChangedFuncPtr _Nonnull func;\n        void (* _Nonnull unlock)();"
      )
      source = source.replacingOccurrences(
        of: "PXR_NAMESPACE_CLOSE_SCOPE",
        with: """
        PXR_NAMESPACE_CLOSE_SCOPE

        void __retain__ZN3Pixar9TfRefBaseE(Pixar::TfRefBase * _Nonnull x);
        void __release__ZN3Pixar9TfRefBaseE(Pixar::TfRefBase * _Nonnull x);
        """
      )
    }

    /** Replaces duplicate-default-arg fwd-decl of Sdf_EvalQuotedString with #include parserHelpers.h before the namespace. */
    public static func predicateExpressionParserHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "predicateExpressionParser.h" else { return }
      // Replace: fwd-decl inside namespace -> include parserHelpers.h before namespace
      source = source.replacingOccurrences(
        of: "#include <memory>\n\nPXR_NAMESPACE_OPEN_SCOPE\n\n// fwd decl, from parserHelpers.cpp.\nstd::string\nSdf_EvalQuotedString(const char* x, size_t n,\n                     size_t trimBothSides, unsigned int* numLines=NULL);",
        with: "#include <memory>\n\n#include \"Sdf/parserHelpers.h\"\n\nPXR_NAMESPACE_OPEN_SCOPE"
      )
    }

    /** Appends missing token declarations for in-dev targets (e.g. ExecIr tokens needed by UsdExecImaging). */
    public static func addMissingTokens(to source: inout String, fileBaseName: String, target: String)
    {
      guard fileBaseName == "tokens.h" else { return }
      
      if target == "ExecIr"
      {
        source = source.replacingOccurrences(
          of: "    ((outSpaceToken, \"Out:Space\"))\n",
          with: "    ((outSpaceToken, \"Out:Space\"))              \\\n"
            + "                                                \\\n"
            + "    ((posedSpace, \"posed:space\"))               \\\n"
            + "                                                \\\n"
            + "    ((guideDisplayColor, \"guide:displayColor\")) \\\n"
            + "    ((guideDisplayOpacity, \"guide:displayOpacity\")) \\\n"
            + "    ((guideLength, \"guide:length\"))\n"
        )
      }
    }

    /** Replaces ARCH_PRAGMA_UNUSED_FUNCTION with inline _Pragma equivalent so openexr-c.c avoids importing the Arch C++ module. */
    public static func openexrCSource(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "openexr-c.c" else { return }

      source = source.replacingOccurrences(of: "#include \"Arch/pragmas.h\"\n", with: "")
      source = source.replacingOccurrences(
        of: "ARCH_PRAGMA_UNUSED_FUNCTION",
        with: "#if defined(__clang__)\n"
          + "_Pragma(\"clang diagnostic ignored \\\"-Wunused-function\\\"\")\n"
          + "#elif defined(__GNUC__)\n"
          + "_Pragma(\"GCC diagnostic ignored \\\"-Wunused-function\\\"\")\n"
          + "#elif defined(_MSC_VER)\n"
          + "__pragma(warning(disable:4505))\n"
          + "#endif"
      )
    }

    /** MaterialX 1.38.X TypeDesc has no operator==; use getName() string comparison. */
    public static func materialXShaderGen(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "materialXShaderGen.cpp" else { return }
      for (old, new) in [
        ("return typeDesc == *mx::Type::NONE;",          "return typeDesc.getName() == mx::Type::NONE->getName();"),
        ("return typeDesc == *mx::Type::SURFACESHADER;", "return typeDesc.getName() == mx::Type::SURFACESHADER->getName();"),
        ("return typeDesc == *mx::Type::FILENAME;",      "return typeDesc.getName() == mx::Type::FILENAME->getName();"),
      ] { source = source.replacingOccurrences(of: old, with: new) }
    }

    public static func glslfxToolsPaths(to source: inout String)
    {
      for (old, new) in [
        ("$TOOLS/hdSt/", "$TOOLS/HdSt/"),
        ("$TOOLS/hdx/",  "$TOOLS/Hdx/"),
        ("$TOOLS/glf/",  "$TOOLS/Glf/"),
      ] { source = source.replacingOccurrences(of: old, with: new) }
    }

    /** Rewrites double-quote same-directory includes to angle-bracket module includes (e.g. "foo.h" -> <Target/foo.h>). subdirectory preserves vendored sub-paths. */
    public static func sameDirectoryIncludes(to source: inout String, target: String, subdirectory: String? = nil)
    {
      // Apple SDK header - angle brackets.
      source = source.replacingOccurrences(of: "#include \"TargetConditionals.h\"", with: "#include <TargetConditionals.h>")

      // Gf/nc/ vendored nanocolor sub-library.
      source = source.replacingOccurrences(of: "#include \"nanocolor.h\"", with: "#include <Gf/nc/nanocolor.h>")

      // Tf/pxrLZ4/ vendored LZ4 sub-library.
      source = source.replacingOccurrences(of: "#include \"lz4.h\"", with: "#include <Tf/pxrLZ4/lz4.h>")

      // Tf/pxrDoubleConversion/ vendored double-conversion sub-library.
      if target == "Tf"
      {
        for h in ["bignum.h", "bignum-dtoa.h", "cached-powers.h", "diy-fp.h",
                  "double-to-string.h", "fast-dtoa.h", "fixed-dtoa.h", "ieee.h",
                  "string-to-double.h", "strtod.h", "utils.h"]
        {
          source = source.replacingOccurrences(of: "#include \"\(h)\"", with: "#include <Tf/pxrDoubleConversion/\(h)>")
        }
        // Tf/pxrTslRobinMap/ vendored robin-map sub-library. The general rule below
        // would produce <Tf/robin_hash.h> etc. (flattened), but the files live under
        // pxrTslRobinMap/ and must be included with that sub-path.
        for h in ["robin_hash.h", "robin_growth_policy.h", "robin_map.h", "robin_set.h"]
        {
          source = source.replacingOccurrences(of: "#include \"\(h)\"", with: "#include <Tf/pxrTslRobinMap/\(h)>")
        }
      }

      // general rule: any remaining `#include "X.h"` with no path separator ->
      // `#include <Target/X.h>` (top-level) or `#include <Target/subdir/X.h>` when
      // the file lives in a preserved subdirectory (e.g. Pegtl/internal/).
      guard let regex = try? NSRegularExpression(pattern: #"#include "([^/"]+\.(?:h|hpp|hxx))""#)
      else { return }

      let nsSource = source as NSString
      let range = NSRange(location: 0, length: nsSource.length)
      let prefix = subdirectory.map { "\(target)/\($0)" } ?? target
      source = regex.stringByReplacingMatches(in: source, range: range, withTemplate: "#include <\(prefix)/$1>")
    }

    /** Replaces ARCH_HIDDEN-based NCAPI in nanocolor.h with a self-contained visibility macro (avoids importing Arch C++ module). */
    public static func nanocolorHeader(to source: inout String, fileBaseName: String)
    {
      guard fileBaseName == "nanocolor.h" else { return }

      source = source.replacingOccurrences(of: "#include \"Arch/export.h\"\n", with: "")
      source = source.replacingOccurrences(
        of: "#ifndef NCAPI\n#define NCAPI ARCH_HIDDEN\n#endif",
        with: """
        #ifndef NCAPI
        #  if defined(_WIN32) || defined(__CYGWIN__)
        #    define NCAPI
        #  elif defined(__GNUC__) || defined(__clang__)
        #    define NCAPI __attribute__((visibility("hidden")))
        #  else
        #    define NCAPI
        #  endif
        #endif
        """
      )
    }

    /** Wraps platform-specific Garch .cpp variants in #if guards (SwiftPM compiles all sources; upstream relied on CMake exclusion). */
    public static func platformGuardedSource(to source: inout String, fileBaseName: String)
    {
      let guardMacro: String
      var prefix = ""
      switch fileBaseName
      {
      case "darwin.mm":
        guardMacro = "defined(__APPLE__)"
      case "glPlatformContextDarwin.mm", "glPlatformDebugWindowDarwin.mm":
        guardMacro = "defined(__APPLE__)"
      case "hgiInterop.mm":
        guardMacro = "defined(__APPLE__)"
      case "glPlatformContextWindows.cpp", "glPlatformDebugWindowWindows.cpp":
        guardMacro = "defined(_WIN32)"
      case "glPlatformContextGLX.cpp":
        guardMacro = "defined(__ANDROID__) || defined(__linux__)"
      case "glPlatformDebugWindowGLX.cpp":
        guardMacro = "defined(__linux__) && !defined(__ANDROID__)"
      case "vulkan.cpp":
        guardMacro = "0"
      case "metal.mm":
        // ARCH_OS_OSX isn't a compiler-predefined macro -- pull in
        // Arch/defines.h before checking it, matching the guard
        // hgiInterop.mm uses around its #include "HgiInterop/metal.h".
        guardMacro = "PXR_METAL_SUPPORT_ENABLED && defined(ARCH_OS_OSX)"
        prefix = "#include \"Arch/defines.h\"\n\n"
      default:
        return
      }

      guard !source.contains("#if \(guardMacro)") else { return }

      source = prefix + "#if \(guardMacro)\n\n" + source + "\n#endif // \(guardMacro)\n"
    }

    /** Guards Arch/darwin.h content and its unconditional include in Arch.h umbrella. */
    public static func archDarwinHeaders(to source: inout String, fileBaseName: String)
    {
      switch fileBaseName
      {
      case "darwin.h":
        guard !source.contains("#if defined(__APPLE__)") else { return }
        source = source.replacingOccurrences(
          of: "PXR_NAMESPACE_OPEN_SCOPE\n\nconst char* Arch_DarwinGetTemporaryDirectory();\n\nPXR_NAMESPACE_CLOSE_SCOPE",
          with: "#if defined(__APPLE__)\nPXR_NAMESPACE_OPEN_SCOPE\n\nconst char* Arch_DarwinGetTemporaryDirectory();\n\nPXR_NAMESPACE_CLOSE_SCOPE\n#endif // defined(__APPLE__)"
        )
      default:
        return
      }
    }

    /** Excludes Android from Linux-only Arch code that uses glibc/GCC-specific APIs. */
    public static func archAndroid(to source: inout String, fileBaseName: String)
    {
      switch fileBaseName
      {
      case "stackTrace.cpp":
        // nonLockingLinux__execve uses GCC register-label asm (unsupported on Clang/Android)
        // and __environ (glibc-only; Bionic uses environ). Route Android through plain execv.
        source = source.replacingOccurrences(
          of: "#if defined(ARCH_OS_LINUX)\nstatic int\nnonLockingLinux__execve",
          with: "#if defined(ARCH_OS_LINUX) && !defined(ARCH_OS_ANDROID)\nstatic int\nnonLockingLinux__execve"
        )
        source = source.replacingOccurrences(
          of: "#if defined(ARCH_OS_LINUX)\n     return nonLockingLinux__execve (path, argv, __environ);",
          with: "#if defined(ARCH_OS_LINUX) && !defined(ARCH_OS_ANDROID)\n     return nonLockingLinux__execve (path, argv, __environ);"
        )

      case "daemon.cpp":
        // Android Bionic doesn't define NOFILE; use sysconf(_SC_OPEN_MAX) as fallback.
        source = source.replacingOccurrences(
          of: "    if (limits.rlim_cur == RLIM_INFINITY)\n    {\n        maxfd = NOFILE;\n    }",
          with: "    if (limits.rlim_cur == RLIM_INFINITY)\n    {\n#  if defined(NOFILE)\n        maxfd = NOFILE;\n#  else\n        maxfd = (int)sysconf(_SC_OPEN_MAX);\n        if (maxfd < 0) maxfd = 256;\n#  endif\n    }"
        )

      default:
        return
      }
    }

    /** Adds ARCH_OS_ANDROID alongside ARCH_OS_LINUX in Arch/defines.h, and fixes
     *  Garch to use EGL instead of GLX on Android (glPlatformContextGLX.h/.cpp + glApi.cpp). */
    public static func garchAndroid(to source: inout String, fileBaseName: String)
    {
      switch fileBaseName
      {
        case "glDebugWindow.cpp":
          // Android has no debug window, exclude it
          // from the Linux branch and insert a no-op
          // stub so the type is always complete.
          source = source.replacingOccurrences(
            of: "#if defined(ARCH_OS_LINUX)\n",
            with: "#if defined(ARCH_OS_LINUX) && !defined(ARCH_OS_ANDROID)\n"
          )
          source = source.replacingOccurrences(
            of: "#endif\n\nPXR_NAMESPACE_OPEN_SCOPE\n\nGarchGLDebugWindow",
            with: "#elif defined(ARCH_OS_ANDROID)\nPXR_NAMESPACE_OPEN_SCOPE\nclass Garch_GLPlatformDebugWindow {\npublic:\n    Garch_GLPlatformDebugWindow(GarchGLDebugWindow*) {}\n    void Init(const char*, int, int) {}\n    void Run() {}\n    void ExitApp() {}\n};\nPXR_NAMESPACE_CLOSE_SCOPE\n#endif\n\nPXR_NAMESPACE_OPEN_SCOPE\n\nGarchGLDebugWindow"
          )

        case "defines.h":
          source = source.replacingOccurrences(
            of: "#elif defined(__linux__)\n#define ARCH_OS_LINUX",
            with: "#elif defined(__linux__)\n#define ARCH_OS_LINUX\n#if defined(__ANDROID__)\n#define ARCH_OS_ANDROID\n#endif"
          )

        case "glPlatformDebugContext.cpp":
          // Exclude Android from the GLX/X11 debug context; add a no-op stub like Darwin/Windows.
          source = source.replacingOccurrences(
            of: "#if defined(ARCH_OS_LINUX)\n\n#include <GL/glx.h>",
            with: "#if defined(ARCH_OS_LINUX) && !defined(ARCH_OS_ANDROID)\n\n#include <GL/glx.h>"
          )
          source = source.replacingOccurrences(
            of: "#endif // ARCH_OS_LINUX\n\n////////////////////////////////////////////////////////////\n\n#if defined(ARCH_OS_DARWIN)",
            with: "#endif // ARCH_OS_LINUX && !ARCH_OS_ANDROID\n\n////////////////////////////////////////////////////////////\n\n#if defined(ARCH_OS_ANDROID)\n\nPXR_NAMESPACE_OPEN_SCOPE\n\nclass GarchGLPlatformDebugContextPrivate {\npublic:\n    GarchGLPlatformDebugContextPrivate(\n        int majorVersion, int minorVersion,\n        bool coreProfile, bool directRendering) {}\n    ~GarchGLPlatformDebugContextPrivate() {}\n\n    void MakeCurrent() {}\n};\n\nvoid *GarchSelectCoreProfileMacVisual()\n{\n    return nullptr;\n}\n\nPXR_NAMESPACE_CLOSE_SCOPE\n\n#endif // ARCH_OS_ANDROID\n\n////////////////////////////////////////////////////////////\n\n#if defined(ARCH_OS_DARWIN)"
          )

        case "glPlatformContextGLX.h":
          source = source.replacingOccurrences(
            of: "#include \"pxr/pxrns.h\"\n#include <GL/glx.h>",
            with: "#include \"pxr/pxrns.h\"\n\n#if defined(__ANDROID__)\n\n#include <EGL/egl.h>"
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_OPEN_SCOPE\n\n\nclass GarchGLXContextState {",
            with: "PXR_NAMESPACE_OPEN_SCOPE\n\nclass GarchEGLContextState {\npublic:\n    GarchEGLContextState();\n    GarchEGLContextState(EGLDisplay, EGLSurface, EGLContext);\n    bool operator==(const GarchEGLContextState& rhs) const;\n    size_t GetHash() const;\n    bool IsValid() const;\n    void MakeCurrent();\n    static void DoneCurrent();\npublic:\n    EGLDisplay display;\n    EGLSurface drawable;\n    EGLContext context;\nprivate:\n    bool _defaultCtor;\n};\n\ntypedef GarchEGLContextState GarchGLPlatformContextState;\n\nPXR_NAMESPACE_CLOSE_SCOPE\n\n#else // !defined(__ANDROID__)\n\n#include <GL/glx.h>\n\nPXR_NAMESPACE_OPEN_SCOPE\n\nclass GarchGLXContextState {"
          )
          source = source.replacingOccurrences(
            of: "// Hide the platform specific type name behind a common name.\ntypedef GarchGLXContextState GarchGLPlatformContextState;\n\n\nPXR_NAMESPACE_CLOSE_SCOPE",
            with: "typedef GarchGLXContextState GarchGLPlatformContextState;\n\nPXR_NAMESPACE_CLOSE_SCOPE\n\n#endif // defined(__ANDROID__)"
          )

        case "glPlatformContextGLX.cpp":
          // Replace GLX-only implementation with EGL (Android) / GLX (Linux) split.
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_OPEN_SCOPE\n\n\n//\n// GarchGLXContextState\n//\n\nGarchGLXContextState::GarchGLXContextState() :",
            with: "PXR_NAMESPACE_OPEN_SCOPE\n\n#if defined(__ANDROID__)\n\n//\n// GarchEGLContextState\n//\n\nGarchEGLContextState::GarchEGLContextState() :\n    display(eglGetCurrentDisplay()),\n    drawable(eglGetCurrentSurface(EGL_DRAW)),\n    context(eglGetCurrentContext()),\n    _defaultCtor(true)\n{\n}\n\nGarchEGLContextState::GarchEGLContextState(\n    EGLDisplay display_, EGLSurface drawable_, EGLContext context_) :\n    display(display_), drawable(drawable_), context(context_),\n    _defaultCtor(false)\n{\n}\n\nbool\nGarchEGLContextState::operator==(const GarchEGLContextState& rhs) const\n{\n    return display  == rhs.display  &&\n           drawable == rhs.drawable &&\n           context  == rhs.context;\n}\n\nsize_t\nGarchEGLContextState::GetHash() const\n{\n    return TfHash::Combine(\n        display,\n        drawable,\n        context\n    );\n}\n\nbool\nGarchEGLContextState::IsValid() const\n{\n    return display != EGL_NO_DISPLAY &&\n           drawable != EGL_NO_SURFACE &&\n           context  != EGL_NO_CONTEXT;\n}\n\nvoid\nGarchEGLContextState::MakeCurrent()\n{\n    if (IsValid()) {\n        eglMakeCurrent(display, drawable, drawable, context);\n    }\n    else if (_defaultCtor) {\n        DoneCurrent();\n    }\n}\n\nvoid\nGarchEGLContextState::DoneCurrent()\n{\n    if (EGLDisplay dpy = eglGetCurrentDisplay()) {\n        eglMakeCurrent(dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);\n    }\n}\n\nGarchGLPlatformContextState\nGarchGetNullGLPlatformContextState()\n{\n    return GarchEGLContextState(EGL_NO_DISPLAY, EGL_NO_SURFACE, EGL_NO_CONTEXT);\n}\n\n#else // !defined(__ANDROID__)\n\n//\n// GarchGLXContextState\n//\n\nGarchGLXContextState::GarchGLXContextState() :"
          )
          source = source.replacingOccurrences(
            of: "GarchGLPlatformContextState\nGarchGetNullGLPlatformContextState()\n{\n    return GarchGLXContextState(NULL, None, NULL);\n}\n\nPXR_NAMESPACE_CLOSE_SCOPE",
            with: "GarchGLPlatformContextState\nGarchGetNullGLPlatformContextState()\n{\n    return GarchGLXContextState(NULL, None, NULL);\n}\n\n#endif // defined(__ANDROID__)\n\nPXR_NAMESPACE_CLOSE_SCOPE"
          )

        case "glApi.cpp":
          // Add libEGLHandle static for Android alongside the existing libHandle.
          source = source.replacingOccurrences(
            of: "static void* libHandle = NULL;\n#if !defined(ARCH_OS_DARWIN)",
            with: "static void* libHandle = NULL;\n#if defined(ARCH_OS_ANDROID)\nstatic void* libEGLHandle = NULL;\n#endif\n#if !defined(ARCH_OS_DARWIN)"
          )
          // Open libGLESv2 (dlsym fallback) + libEGL (eglGetProcAddress) on Android.
          source = source.replacingOccurrences(
            of: "#elif defined(ARCH_OS_LINUX)\n    libHandle = ArchLibraryOpen(\"libGL.so.1\", RTLD_LAZY | RTLD_LOCAL);\n    libGetProcAddress = (PFNGETPROCADDRESS) ArchLibraryGetSymbolAddress(libHandle, \"glXGetProcAddressARB\");",
            with: "#elif defined(ARCH_OS_LINUX)\n#if defined(ARCH_OS_ANDROID)\n    libHandle    = ArchLibraryOpen(\"libGLESv2.so\", RTLD_LAZY | RTLD_LOCAL);\n    libEGLHandle = ArchLibraryOpen(\"libEGL.so\",    RTLD_LAZY | RTLD_LOCAL);\n    libGetProcAddress = (PFNGETPROCADDRESS) ArchLibraryGetSymbolAddress(libEGLHandle, \"eglGetProcAddress\");\n#else\n    libHandle = ArchLibraryOpen(\"libGL.so.1\", RTLD_LAZY | RTLD_LOCAL);\n    libGetProcAddress = (PFNGETPROCADDRESS) ArchLibraryGetSymbolAddress(libHandle, \"glXGetProcAddressARB\");\n#endif"
          )

        case "glPlatformDebugWindowGLX.h":
          // Guard X11/GLX headers and class body against Android - debug window is desktop-only.
          // Anchor on the system header (never rewritten) rather than Tf/declarePtrs.h
          // which is still in pxr/base/tf/ form when this patch runs.
          source = source.replacingOccurrences(
            of: "#include <X11/Xlib.h>\n#include <GL/glx.h>",
            with: "#if !defined(__ANDROID__)\n#include <X11/Xlib.h>\n#include <GL/glx.h>"
          )
          source = source.replacingOccurrences(
            of: "PXR_NAMESPACE_CLOSE_SCOPE\n\n#endif  // PXR_IMAGING_GARCH_GL_PLATFORM_DEBUG_WINDOW_GLX_H",
            with: "PXR_NAMESPACE_CLOSE_SCOPE\n\n#endif  // !defined(__ANDROID__)\n\n#endif  // PXR_IMAGING_GARCH_GL_PLATFORM_DEBUG_WINDOW_GLX_H"
          )

        default:
          return
      }
    }

    /** Guards boost/python includes and rewrites #ifdef->#if checks for PXR_PYTHON_SUPPORT_ENABLED. */
    public static func pythonIncludes(to source: inout String)
    {
      // Package.swift always defines PXR_PYTHON_SUPPORT_ENABLED (to 0 or 1),
      // so #ifdef/#ifndef checks are always true/false. rewrite to value
      // checks so the macro's value is honored.
      source = source.replacingOccurrences(of: "#ifdef PXR_PYTHON_SUPPORT_ENABLED", with: "#if PXR_PYTHON_SUPPORT_ENABLED")
      source = source.replacingOccurrences(of: "#ifndef PXR_PYTHON_SUPPORT_ENABLED", with: "#if !PXR_PYTHON_SUPPORT_ENABLED")

      guard !source.contains("PXR_PYTHON_SUPPORT_ENABLED") else { return }

      let lines = source.components(separatedBy: "\n")
      var result: [String] = []
      result.reserveCapacity(lines.count)

      for line in lines
      {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("#include"), trimmed.contains("boost/python")
        {
          result.append("#if PXR_PYTHON_SUPPORT_ENABLED")
          result.append(line)
          result.append("#endif // PXR_PYTHON_SUPPORT_ENABLED")
        }
        else
        {
          result.append(line)
        }
      }

      source = result.joined(separator: "\n")
    }

    /** Wraps python-only files in #if PXR_PYTHON_SUPPORT_ENABLED (mirrors CMake's source exclusion when python is off). */
    public static func pythonGuards(to source: inout String, fileBaseName: String, pythonOnlyBasenames: Set<String>)
    {
      guard pythonOnlyBasenames.contains(fileBaseName) else { return }

      let lines = source.components(separatedBy: "\n")

      // find end of preamble (license/guard/#includes) -- track `/* */`
      // blocks so #if/#endif-looking text inside one (ex.
      // scriptModuleLoader.cpp's notes) isn't mistaken for real directives.
      var bodyStart = 0
      var inBlockComment = false
      while bodyStart < lines.count
      {
        let trimmed = lines[bodyStart].trimmingCharacters(in: .whitespaces)
        if inBlockComment
        {
          if trimmed.contains("*/") { inBlockComment = false }
          bodyStart += 1
          continue
        }
        if trimmed.hasPrefix("/*")
        {
          if !trimmed.contains("*/") { inBlockComment = true }
          bodyStart += 1
          continue
        }
        if trimmed.isEmpty || trimmed.hasPrefix("//") || trimmed.hasPrefix("#")
        {
          bodyStart += 1
          continue
        }
        break
      }
      guard bodyStart < lines.count else { return }

      // for headers, the trailing `#endif` closes the `#ifndef`/`#define`
      // include guard and must remain outside the wrapper.
      var bodyEnd = lines.count
      while bodyEnd > bodyStart, lines[bodyEnd - 1].trimmingCharacters(in: .whitespaces).isEmpty
      {
        bodyEnd -= 1
      }
      var trailingGuardEndif: String? = nil
      if bodyEnd > bodyStart, lines[bodyEnd - 1].trimmingCharacters(in: .whitespaces).hasPrefix("#endif")
      {
        trailingGuardEndif = lines[bodyEnd - 1]
        bodyEnd -= 1
        while bodyEnd > bodyStart, lines[bodyEnd - 1].trimmingCharacters(in: .whitespaces).isEmpty
        {
          bodyEnd -= 1
        }
      }

      var result = Array(lines[0..<bodyStart])
      result.append("#if PXR_PYTHON_SUPPORT_ENABLED")
      result.append(contentsOf: lines[bodyStart..<bodyEnd])
      result.append("#endif // PXR_PYTHON_SUPPORT_ENABLED")
      if let trailingGuardEndif
      {
        result.append("")
        result.append(trailingGuardEndif)
      }

      source = result.joined(separator: "\n")
    }

    /** Global source patches: namespace, include paths, ABI fixes. */
    public static func headers(to source: inout String)
    {
      source = source.replacingOccurrences(of: "pxr/pxr.h",    with: "pxr/pxrns.h")
      source = source.replacingOccurrences(of: "pxr/external/", with: "")

      // Impl-renamed umbrella headers (see collidingUmbrellaInclude).
      source = source.replacingOccurrences(of: "tf/tf.h",      with: "Tf/tfImpl.h")
      source = source.replacingOccurrences(of: "trace/trace.h", with: "Trace/traceImpl.h")
      source = source.replacingOccurrences(of: "ar/ar.h",      with: "Ar/arImpl.h")
      source = source.replacingOccurrences(of: "hgi/hgi.h",    with: "Hgi/hgiImpl.h")
      source = source.replacingOccurrences(of: "hgiInterop.h", with: "hgiInteropImpl.h")

      source = source.replacingOccurrences(of: "#include \"pegtl/",           with: "#include \"Pegtl/")
      source = source.replacingOccurrences(of: "#include \"pxr/imaging/hdsi/", with: "#include \"HdSi/")
      source = source.replacingOccurrences(of: "#include \"shaderSection.h\"",  with: "#include \"Hgi/shaderSection.h\"")

      // Inject Tf_RetainReleaseHelper friendship alongside Tf_RefPtr_Counter.
      source = source.replacingOccurrences(of: "friend struct Tf_RefPtr_Counter;", with: "friend struct Tf_RefPtr_Counter;\n    friend class Tf_RetainReleaseHelper;")

      // vt/dictionary.h + sdf/types.h included inside a namespace - hoist around it.
      source = source.replacingOccurrences(
        of: "#include \"pxr/base/vt/dictionary.h\"\n#include \"pxr/usd/sdf/types.h\"",
        with: "PXR_NAMESPACE_CLOSE_SCOPE\n#include \"pxr/base/vt/dictionary.h\"\n#include \"pxr/usd/sdf/types.h\"\nPXR_NAMESPACE_OPEN_SCOPE"
      )

      // cleanupTracker.h has #include <vector> inside PXR_NAMESPACE_OPEN_SCOPE - hoist above.
      source = source.replacingOccurrences(
        of: "PXR_NAMESPACE_OPEN_SCOPE\n\nSDF_DECLARE_HANDLES(SdfSpec);\n\n#include <vector>",
        with: "#include <vector>\n\nPXR_NAMESPACE_OPEN_SCOPE\n\nSDF_DECLARE_HANDLES(SdfSpec);"
      )


      // Normalize feature-flag macros from defined() to direct #if form.
      source = source.replacingOccurrences(of: "#if defined(PXR_GL_SUPPORT_ENABLED)",     with: "#if PXR_GL_SUPPORT_ENABLED")
      source = source.replacingOccurrences(of: "#if defined(PXR_VULKAN_SUPPORT_ENABLED)", with: "#if PXR_VULKAN_SUPPORT_ENABLED")
      source = source.replacingOccurrences(of: "#if defined(PXR_METAL_SUPPORT_ENABLED)",  with: "#if PXR_METAL_SUPPORT_ENABLED")

      // noexcept on virtual dtors avoids ABI-mismatch warnings.
      source = source.replacingOccurrences(of: "virtual ~SdfLayer();", with: "virtual ~SdfLayer() noexcept;")
      source = source.replacingOccurrences(of: "virtual ~UsdStage();", with: "virtual ~UsdStage() noexcept;")

      // TF_WARN / TF_FATAL_ERROR / TF_RUNTIME_ERROR: printf-style macros - pass c_str() for std::string args.
      source = source.replacingOccurrences(
        of: "TF_WARN(s.str());",
        with: "TF_WARN(\"%s\", s.str().c_str());"
      )
      source = source.replacingOccurrences(
        of: "TF_FATAL_ERROR(\"Attempted to get value for key '\" + key +\n                       \"', which is not in the dictionary.\");",
        with: "TF_FATAL_ERROR(\"Attempted to get value for key '%s', \"\n                       \"which is not in the dictionary.\", key.c_str());"
      )
      source = source.replacingOccurrences(
        of: "TF_RUNTIME_ERROR(errs);",
        with: "TF_RUNTIME_ERROR(\"%s\", errs.c_str());"
      )
      source = source.replacingOccurrences(
        of: "TF_WARN(\n                \"No value set for output \" + output.GetDebugName() +\n                \" of type \" + output.GetSpec().GetType().GetTypeName() +\n                \" named \" + output.GetName().GetString());",
        with: "TF_WARN(\"%s\", (\"No value set for output \" + output.GetDebugName() +\n                \" of type \" + output.GetSpec().GetType().GetTypeName() +\n                \" named \" + output.GetName().GetString()).c_str());"
      )

      // TBB: MetaverseKit places tbb under OneTBB/; deprecated atomic/mutex/task_scheduler_init -> std.
      source = source.replacingOccurrences(of: "<tbb/", with: "<OneTBB/tbb/")
      source = source.replacingOccurrences(of: "\"tbb/", with: "\"OneTBB/tbb/")
      source = source.replacingOccurrences(of: "<tbb/atomic.h>", with: "<atomic>")
      source = source.replacingOccurrences(of: "tbb::atomic", with: "std::atomic")
      source = source.replacingOccurrences(of: "<tbb/mutex.h>", with: "<mutex>")
      source = source.replacingOccurrences(of: "tbb::mutex", with: "std::mutex")
      source = source.replacingOccurrences(of: "#include <OneTBB/tbb/task_scheduler_init.h>",
        with: "#if WITH_TBB_LEGACY\n#include <OneTBB/tbb/task_scheduler_init.h>\n#endif")

      // MaterialX: upstream uses per-submodule paths; MetaverseKit exposes a flat MX*.h layout.
      let materialXHeaders: [(String, String)] = [
        ("MaterialXCore/Document.h",                         "MaterialX/MXCoreDocument.h"),
        ("MaterialXCore/Util.h",                             "MaterialX/MXCoreUtil.h"),
        ("MaterialXCore/Library.h",                          "MaterialX/MXCoreLibrary.h"),
        ("MaterialXCore/Node.h",                             "MaterialX/MXCoreNode.h"),
        ("MaterialXCore/Value.h",                            "MaterialX/MXCoreValue.h"),
        ("MaterialXCore/Generated.h",                        "MaterialX/MXCoreGenerated.h"),
        ("MaterialXFormat/Util.h",                           "MaterialX/MXFormatUtil.h"),
        ("MaterialXFormat/XmlIo.h",                          "MaterialX/MXFormatXmlIo.h"),
        ("MaterialXFormat/Environ.h",                        "MaterialX/MXFormatEnviron.h"),
        ("MaterialXGenShader/Shader.h",                      "MaterialX/MXGenShader.h"),
        ("MaterialXGenShader/ShaderGenerator.h",             "MaterialX/MXGenShaderGenerator.h"),
        ("MaterialXGenShader/Syntax.h",                      "MaterialX/MXGenShaderSyntax.h"),
        ("MaterialXGenShader/Util.h",                        "MaterialX/MXGenShaderUtil.h"),
        ("MaterialXGenShader/DefaultColorManagementSystem.h","MaterialX/MXGenShaderDefaultColorManagementSystem.h"),
        ("MaterialXGenGlsl/GlslShaderGenerator.h",           "MaterialX/MXGenGlslShaderGenerator.h"),
        ("MaterialXGenGlsl/Nodes/SurfaceNodeGlsl.h",         "MaterialX/MXGenGlslSurfaceNodeGlsl.h"),
        ("MaterialXGenGlsl/VkShaderGenerator.h",             "MaterialX/MXGenGlslVkShaderGenerator.h"),
        ("MaterialXGenMsl/MslShaderGenerator.h",             "MaterialX/MXGenMslShaderGenerator.h"),
        ("MaterialXGenMsl/Nodes/SurfaceNodeMsl.h",           "MaterialX/MXGenMslSurfaceNodeMsl.h"),
        ("MaterialXGenMsl/MslResourceBindingContext.h",      "MaterialX/MXGenMslResourceBindingContext.h"),
        ("MaterialXRender/Util.h",                           "MaterialX/MXRenderUtil.h"),
        ("MaterialXRender/LightHandler.h",                   "MaterialX/MXRenderLightHandler.h"),
        ("MaterialXRenderGlsl/TextureBaker.h",               "MaterialX/MXRenderGlslTextureBaker.h"),
      ]
      for (upstream, flat) in materialXHeaders
      {
        source = source.replacingOccurrences(of: "#include <\(upstream)>", with: "#include <\(flat)>")
      }

      // OpenSubdiv: upstream uses "opensubdiv/<lib>/<hdr>"; MetaverseKit exposes flat "OpenSubdiv/OSD*.h".
      let openSubdivHeaders: [(String, String)] = [
        ("opensubdiv/version.h",                    "OpenSubdiv/OSDVersion.h"),
        ("opensubdiv/far/topologyRefiner.h",        "OpenSubdiv/OSDAdaptiveTopologyRefiner.h"),
        ("opensubdiv/far/topologyRefinerFactory.h", "OpenSubdiv/OSDAdaptiveTopologyRefinerFactory.h"),
        ("opensubdiv/far/patchTable.h",             "OpenSubdiv/OSDAdaptivePatchTable.h"),
        ("opensubdiv/far/patchTableFactory.h",      "OpenSubdiv/OSDAdaptivePatchTableFactory.h"),
        ("opensubdiv/far/stencilTable.h",           "OpenSubdiv/OSDAdaptiveStencilTable.h"),
        ("opensubdiv/far/stencilTableFactory.h",    "OpenSubdiv/OSDAdaptiveStencilTableFactory.h"),
        ("opensubdiv/osd/mtlPatchShaderSource.h",   "OpenSubdiv/OSDSurfaceMTLPatchShaderSource.h"),
        ("opensubdiv/osd/glslPatchShaderSource.h",  "OpenSubdiv/OSDSurfaceGLSLPatchShaderSource.h"),
      ]
      for (upstream, flattened) in openSubdivHeaders
      {
        source = source.replacingOccurrences(of: "#include <\(upstream)>", with: "#include <\(flattened)>")
      }
      
      source = source.replacingOccurrences(of: "#include \"nc/nanocolor.h\"",      with: "#include \"nanocolor.h\"")
      source = source.replacingOccurrences(of: "#include \"colorSpace_data.h\"",   with: "#include \"Gf/colorSpace_data.h\"")

      // didModifyRange: is on MTLBuffer, not MTLResource.
      source = source.replacingOccurrences(of: "id<MTLResource> resource = metalBuffer->GetBufferId();", with: "id<MTLBuffer> resource = metalBuffer->GetBufferId();")

      // ObjC id -> void* bridging: NSOpenGLPixelFormat alloc needs __bridge for a void* return.
      source = source.replacingOccurrences(of: "return [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];", with: "return (__bridge void*)[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];")

      // GetRawResource() is uint64_t; C-style cast to id<MTLTexture> disallowed under ARC - go via void*.
      source = source.replacingOccurrences(of: "colorTexture = id<MTLTexture>(color->GetRawResource());", with: "colorTexture = (__bridge id<MTLTexture>)(void*)color->GetRawResource();")
      source = source.replacingOccurrences(of: "depthTexture = id<MTLTexture>(depth->GetRawResource());", with: "depthTexture = (__bridge id<MTLTexture>)(void*)depth->GetRawResource();")
    }

    /** Wraps [obj retain]/[obj release] lines in #if !__has_feature(objc_arc) guards (.m/.mm only). */
    public static func arcRetainReleaseGuards(to source: inout String, fileExtension: String)
    {
      guard fileExtension == "m" || fileExtension == "mm" else { return }

      let retainReleaseLine = /^\s*\[.+\s(?:retain|release)\];\s*$/

      let lines = source.components(separatedBy: "\n")
      var result: [String] = []
      result.reserveCapacity(lines.count)

      var ifDepth = 0
      var arcGuardDepth = 0

      var i = 0
      while i < lines.count
      {
        let line = lines[i]
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("#if")
        {
          ifDepth += 1
          if trimmed.contains("!__has_feature(objc_arc)")
          {
            arcGuardDepth = ifDepth
          }
          result.append(line)
          i += 1
          continue
        }

        if trimmed.hasPrefix("#endif")
        {
          if ifDepth == arcGuardDepth { arcGuardDepth = 0 }
          ifDepth -= 1
          result.append(line)
          i += 1
          continue
        }

        if arcGuardDepth == 0, (try? retainReleaseLine.firstMatch(in: line)) != nil
        {
          var group: [String] = []
          while i < lines.count, (try? retainReleaseLine.firstMatch(in: lines[i])) != nil
          {
            group.append(lines[i])
            i += 1
          }

          result.append("#if !__has_feature(objc_arc)")
          result.append(contentsOf: group)
          result.append("#endif // !__has_feature(objc_arc)")
          continue
        }

        result.append(line)
        i += 1
      }

      source = result.joined(separator: "\n")
    }
  }
}
