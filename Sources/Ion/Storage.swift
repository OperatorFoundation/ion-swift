//
//  Storage.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

import BigNumber
import Datable
import Transmission

public struct Storage
{
  static func identity(i: Storage) -> Storage
  {
    return i;
  }

  public let o: Int
  public let t: Int
  public let i: I

  public init(o: Int, t: Int, i: I)
  {
    self.o = o
    self.t = t
    self.i = i
  }

  public init(x: Storage)
  {
    self.o = x.o
    self.t = x.t
    self.i = x.i
  }

  public func truth() -> Int
  {
    switch(self.o)
    {
      case NounType.INTEGER.rawValue:
        switch(self.t)
        {
          case StorageType.WORD.rawValue:
            switch(self.i)
            {
              case .word(let integer):
                if(integer == 0)
                {
                  return 1
                }
                else
                {
                  return 0
                }

              default:
                return 0
            }

          default:
            return 0
        }

      default:
        return 0
    }
  }
}

extension Storage: Equatable
{
  public static func ==(lhs: Storage, rhs: Storage) -> Bool
  {
    if(lhs.o != rhs.o)
    {
      return false
    }

    if(lhs.t != rhs.t)
    {
      return false
    }

    switch(lhs.i)
    {
      case .word(let li):
        switch(rhs.i)
        {
          case .word(let ri):
            return li == ri

          default:
            return false
        }

      case .float(let li):
        switch(rhs.i)
        {
          case .float(let ri):
            return li == ri // FIXME - add tolerance

          default:
            return false
        }
      case .words(let lis):
        switch(rhs.i)
        {
          case .words(let ris):
            return lis == ris

          default:
            return false
        }
      case .floats(let lis):
        switch(rhs.i)
        {
          case .floats(let ris):
            return lis == ris

          default:
            return false;
        }
      case .mixed(let lis):
        switch(rhs.i)
        {
          case .mixed(let ris):
            return lis == ris

          default:
            return false;
        }
    }
  }
}

extension Storage: Hashable
{
  public func hash(into hasher: inout Hasher)
  {
    hasher.combine(self.o)
    hasher.combine(self.t)
    hasher.combine(self.i)
  }
}

extension Storage
{
  public var word: Int?
  {
    return self.i.word
  }

  public var float: Float?
  {
    return self.i.float
  }

  public var words: [Int]?
  {
    return self.i.words

  }

  public var floats: [Float]?
  {
    return self.i.floats

  }

  public var mixed: [Storage]?
  {
    return self.i.mixed
  }

  public init(_ value: Int, _ o: Int = NounType.INTEGER.rawValue)
  {
    self.i = .word(value)
    self.o = o
    self.t = StorageType.WORD.rawValue
  }

  public init(_ value: Float, _ o: Int = NounType.REAL.rawValue)
  {
    self.i = .float(value)
    self.o = o
    self.t = StorageType.FLOAT.rawValue
  }

  public init(_ value: [Int], _ o: Int = NounType.LIST.rawValue)
  {
    self.i = .words(value)
    self.o = o
    self.t = StorageType.WORD_ARRAY.rawValue
  }

  public init(_ value: [Float], _ o: Int = NounType.LIST.rawValue)
  {
    self.i = .floats(value)
    self.o = o
    self.t = StorageType.FLOAT_ARRAY.rawValue
  }

  public init(_ value: [Storage], _ o : Int = NounType.LIST.rawValue)
  {
    self.i = .mixed(value)
    self.o = o
    self.t = StorageType.MIXED_ARRAY.rawValue
  }

  public init?(conn: Connection, o: Int)
  {
    guard let v: Varint = expand_conn(conn) else
    {
      return nil
    }

    switch(v)
    {
      case .int(let integer):
        self.init(integer, o)

      case .bint(let bint):
        self = WordArray.make(bint, o)
    }
  }

  public func write(conn: Connection)
  {
    switch(self.i)
    {
      case .word(let ii):
        let typeData: Data = Data([UInt8(self.t), UInt8(self.o)])
        let _ = conn.write(data: typeData)

        let valueData = squeeze_int(ii)
        let _ = conn.write(data: valueData)
      default:
        return
    }
  }
}

extension Storage: MaybeDatable
{
  public var data: Data
  {
    var result: Data = Data()

    result.append(UInt8(self.t))
    result.append(UInt8(self.o))

    if(self.t == StorageType.WORD_ARRAY.rawValue && self.o == NounType.INTEGER.rawValue)
    {
      switch self.i
      {
        case .words(let words):
          guard words.count > 1 else
          {
            return Data()
          }

          guard let bint = BInt(words: words) else
          {
            return Data()
          }

          let valueBytes = squeeze_bigint(bint)

          result.append(valueBytes)

          return result

        default:
          return Data()
      }
    }
    else
    {
      let valueBytes = self.i.data

      result.append(valueBytes)

      return result
    }
  }

  public init?(data: Data)
  {
    if data.count < 3
    {
      return nil
    }

    let tb = data[0]
    let ob = data[1]
    let rest = Data(data[2...])

    guard let tval = StorageType(rawValue: Int(tb)) else
    {
      return nil
    }

    guard let value = I(data: rest, t: tval, o: Int(ob)) else
    {
      return nil
    }

    self.init(o: Int(ob), t: tval.rawValue, i: value)
  }
}
