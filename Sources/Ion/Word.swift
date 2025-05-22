//
//  Word.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

public class Word
{
  static func make(_ x: Int, _ o: Int = NounType.INTEGER.rawValue) -> Storage
  {
    return Storage(o: o, t: StorageType.WORD.rawValue, i: .word(x))
  }
}
