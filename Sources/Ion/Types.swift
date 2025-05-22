//
//  Types.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

import BigNumber

public enum StorageType: Int
{
  case WORD = 0
  case FLOAT = 1
  case WORD_ARRAY = 2
  case FLOAT_ARRAY = 3
  case MIXED_ARRAY = 4
  case ANY = 255
}

public enum NounType: Int
{
  case INTEGER = 0
  case REAL = 1
  case CHARACTER = 2
  case STRING = 3
  case LIST = 4
  case DICTIONARY = 5
  case ANY = 255
}

public enum Varint
{
  case int(Int)
  case bint(BInt)
}

public enum Floating
{
  case float(Float)
  case double(Double)
}
