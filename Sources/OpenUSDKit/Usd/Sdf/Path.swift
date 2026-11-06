/* ----------------------------------------------------------------
 * :: :  M  E  T  A  V  E  R  S  E  :                            ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                                        Copyright (C) 2016 Pixar.
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
#if canImport(Sdf)
  import Sdf
#else
  import OpenUSD
#endif

public typealias SdfPath = Pixar.SdfPath

public extension Sdf
{
  typealias Path = SdfPath
}

public extension Sdf.Path
{
  init(_ path: String)
  {
    self = path.withCString { Overlay.MakePath($0) }
  }

  static func emptyPath() -> Sdf.Path
  {
    #if canImport(Sdf)
      Sdf.Path.EmptyPath().pointee
    #else
      Sdf.Path.EmptyPath()
    #endif
  }

  static func absoluteRootPath() -> Sdf.Path
  {
    #if canImport(Sdf)
      Sdf.Path.AbsoluteRootPath().pointee
    #else
      Sdf.Path.AbsoluteRootPath()
    #endif
  }

  static func reflexiveRelativePath() -> Sdf.Path
  {
    #if canImport(Sdf)
      Sdf.Path.ReflexiveRelativePath().pointee
    #else
      Sdf.Path.ReflexiveRelativePath()
    #endif
  }

  func makeRelativePath(to anchor: Sdf.Path) -> Sdf.Path
  {
    MakeRelativePath(anchor)
  }
  
  func makeAbsolutePath(to anchor: Sdf.Path) -> Sdf.Path
  {
    MakeAbsolutePath(anchor)
  }
  
  func getAsString() -> String
  {
    String(cString: Overlay.GetPathText(self))
  }

  func append(path: Sdf.Path) -> Sdf.Path
  {
    AppendPath(path)
  }

  var string: String
  {
    String(cString: Overlay.GetPathText(self))
  }

  var name: String
  {
    String(cString: Overlay.GetPathNameText(self))
  }
}

#if !canImport(Sdf)
extension Overlay
{
  public static func MakePath(_ path: UnsafePointer<CChar>) -> Sdf.Path
  {
    Sdf.Path(std.string(path))
  }
  
  public static func GetPathText(_ path: Sdf.Path) -> UnsafePointer<CChar>
  {
    String(path.GetString()).withCString { $0 }
  }
  
  // apple/swiftusd is missing Sdf.Path.GetName
  public static func GetPathNameText(_ path: Sdf.Path) -> UnsafePointer<CChar>
  {
    String(String(path.GetString()).split(separator: "/").last ?? "").withCString { $0 }
  }
}
#endif
