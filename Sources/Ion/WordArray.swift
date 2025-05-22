//
//  WordArray.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

import BigNumber
import Transmission

public class WordArray
{
  static func make(_ x: [Int], _ o: Int = NounType.LIST.rawValue) -> Storage
  {
    return Storage(o: o, t: StorageType.WORD_ARRAY.rawValue, i: .words(x))
  }

  static func make(_ x: BInt, _ o: Int = NounType.INTEGER.rawValue) -> Storage
  {
    let (negative, limbs) = x.rawValue
    var uint64s = limbs
    if(negative)
    {
      uint64s.insert(1, at: 0)
    }
    else
    {
      uint64s.insert(0, at: 0)
    }

    let integers = uint64s.map { Int(Int64(bitPattern: $0)) }

    return Storage(integers, o)
  }
}
