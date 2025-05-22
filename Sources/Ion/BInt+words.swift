//
//  BInt+words.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/22/25.
//

import Foundation

import BigNumber

extension BInt
{
  public var words: [Int]
  {
    var (negative, uint64s) = self.rawValue
    if(negative)
    {
      uint64s.insert(1, at: 0)
    }
    else
    {
      uint64s.insert(0, at: 0)
    }

    let ints = uint64s.map { Int(Int64(bitPattern: $0)) }
    return ints
  }

  public init?(words: [Int])
  {
    if words.isEmpty
    {
      return nil
    }

    let negative: Bool = words[0] == 1
    let rest = [Int](words[1...])
    let limbs = rest.map { UInt64(bitPattern: Int64($0)) }

    self.init(sign: negative, limbs: limbs)
  }
}
