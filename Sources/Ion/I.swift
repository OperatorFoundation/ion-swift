//
//  I.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

import Datable
import Transmission

public enum I: Equatable, Hashable
{
  case word(Int)
  case float(Float)
  case words([Int])
  case floats([Float])
  case mixed([Storage])
}

extension I
{
  public var word: Int?
  {
    switch self
    {
      case .word(let value):
        return value

      default:
        return nil
    }
  }

  public var float: Float?
  {
    switch self
    {
      case .float(let value):
        return value

      default:
        return nil
    }
  }

  public var words: [Int]?
  {
    switch self
    {
      case .words(let value):
        return value

      default:
        return nil
    }
  }

  public var floats: [Float]?
  {
    switch self
    {
      case .floats(let value):
        return value

      default:
        return nil
    }
  }

  public var mixed: [Storage]?
  {
    switch self
    {
      case .mixed(let value):
        return value

      default:
        return nil
    }
  }

  public init(_ value: Int)
  {
    self = .word(value)
  }

  public init(_ value: Float)
  {
    self = .float(value)
  }

  public init(_ value: [Int])
  {
    self = .words(value)
  }

  public init(_ value: [Float])
  {
    self = .floats(value)
  }

  public init(_ value: [Storage])
  {
    self = .mixed(value)
  }

  public init?(data: Data, t: StorageType, o: Int)
  {
    switch t
    {
      case StorageType.WORD:
        guard let (varinteger, _) = expand_int(data) else
        {
          return nil
        }

        switch varinteger
        {
          case .int(let value):
            self.init(value)

          case .bint(let value):
            self.init(value.words)
        }

      case StorageType.FLOAT:
        guard let (floating, _) = expand_floating(data) else
        {
          return nil
        }

        switch floating
        {
          case .float(let value):
            self.init(value)

          case .double(let value):
            self.init(Float(value))
        }

      case StorageType.WORD_ARRAY:
        if o == NounType.INTEGER.rawValue
        {
          guard let (varinteger, _) = expand_int(data) else
          {
            return nil
          }

          switch varinteger
          {
            case .int(let value):
              self.init(value)

            case .bint(let value):
              self.init(value.words)
          }
        }
        else
        {
          guard let (integers, _) = expand_ints(data) else
          {
            return nil
          }

          self.init(integers)
        }

      case StorageType.FLOAT_ARRAY:
        guard let (floats, _) = expand_floats(data) else
        {
          return nil
        }

        self.init(floats)

      case StorageType.MIXED_ARRAY:
        guard let (mixed, _) = expand_mixed(data) else
        {
          return nil
        }

        self.init(mixed)

      default:
        return nil
    }
  }

  public init?(conn: Connection, t: StorageType)
  {
    switch t
    {
        // FIXME
//      case StorageType.WORD:
//      case StorageType.FLOAT:
//      case StorageType.WORD_ARRAY:
//      case StorageType.FLOAT_ARRAY:
//      case StorageType.MIXED_ARRAY:

      default:
        return nil
    }
  }

  public var data: Data
  {
    switch self
    {
      case .word(let value):
        return squeeze_int(value)

      case .float(let value):
        return squeeze_floating(.float(value))

      case .words(let value):
        return squeeze_ints(value)

      case .floats(let value):
        return squeeze_floats(value)

      case .mixed(let value):
        return squeeze_mixed(value)
    }
  }
}
