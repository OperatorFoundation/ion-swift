//
//  MixedArray.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

public class MixedArray
{
  static func make(_ x: [Storage], _ o: Int = NounType.LIST.rawValue) -> Storage
  {
    return Storage(o: o, t: StorageType.MIXED_ARRAY.rawValue, i: .mixed(x))
  }
}
