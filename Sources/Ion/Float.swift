//
//  Float.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

extension Float
{
  static func make(_ x: Float, _ o: Int = NounType.REAL.rawValue) -> Storage
  {
    return Storage(o: o, t: StorageType.FLOAT.rawValue, i: .float(x))
  }
}
