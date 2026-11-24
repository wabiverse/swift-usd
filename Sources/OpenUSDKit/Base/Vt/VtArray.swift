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

#if canImport(Gf)
  import Gf
  import Vt
#else
  import OpenUSD
#endif

public typealias VtVec3fArray = Pixar.VtVec3fArray
public typealias VtFloatArray = Pixar.VtFloatArray

public extension Vt
{
  typealias Vec3fArray = VtVec3fArray
  typealias FloatArray = VtFloatArray
}

#if !canImport(Gf)
  public extension Overlay
  {
    /// read only access to the shared storage.
    static func cdata<T: __Overlay.VtArray_Sequence>(_ array: T) -> UnsafePointer<T.ElementType>?
    {
      array.__cdataUnsafe()
    }

    /// one copy from a contiguous buffer.
    static func vtArray<T: __Overlay.VtArrayProtocol>(_ src: UnsafePointer<T.ElementType>?, _ count: Int) -> T
    {
      guard let src, count > 0 else { return T() }
      return T(UnsafeBufferPointer(start: src, count: count))
    }
  }
#endif
