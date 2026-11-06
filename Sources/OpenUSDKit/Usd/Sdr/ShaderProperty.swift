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

#if canImport(Sdr)
  import Sdr
#else
  import OpenUSD
#endif

public typealias SdrShaderProperty = Pixar.SdrShaderProperty

public extension Sdr
{
  typealias ShaderProperty = SdrShaderProperty
}

public extension SdrShaderProperty
{
  /// The name a UI shows the property by.
  var label: Tf.Token
  {
    __GetLabelUnsafe().pointee
  }

  /// The page it sits on, nested pages joined by a colon.
  var page: Tf.Token
  {
    __GetPageUnsafe().pointee
  }

  /// The widget a UI shows it with, such as `checkBox` or `mapper`.
  var widget: Tf.Token
  {
    __GetWidgetUnsafe().pointee
  }

  /// The choices it offers, each a label and the value it stands for.
  var options: [(label: Tf.Token, value: Tf.Token)]
  {
    __GetOptionsUnsafe().pointee.map { ($0.first, $0.second) }
  }

  /// Its default value, held as the Sdf type the property authors.
  var defaultValueAsSdfType: Pixar.VtValue
  {
    __GetDefaultValueAsSdfTypeUnsafe().pointee
  }

  /// The Sdf type the property authors.
  var sdfType: Sdf.ValueTypeName
  {
    GetTypeAsSdfType().sdfType
  }
}

public extension Pixar.SdrSdfTypeIndicator
{
  #if canImport(Sdr)
    private borrowing func GetSdfTypeCopy() -> Sdf.ValueTypeName
    {
      __GetSdfTypeUnsafe()
    }
  #endif

  /// The Sdf type indicated.
  var sdfType: Sdf.ValueTypeName
  {
    #if canImport(Sdr)
      GetSdfTypeCopy()
    #else
      GetSdfType()
    #endif
  }
}
