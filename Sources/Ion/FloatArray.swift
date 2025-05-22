//
//  FloatArray.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

public class FloatArray
{
  static func make(_ x: [Float], _ o: Int = NounType.LIST.rawValue) -> Storage
  {
    return Storage(o: o, t: StorageType.FLOAT_ARRAY.rawValue, i: .floats(x))
  }
}
