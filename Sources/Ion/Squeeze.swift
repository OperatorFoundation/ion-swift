//
//  Squeeze.swift
//  Ion
//
//  Created by Dr. Brandon Wiley on 5/21/25.
//

import Foundation

import BigNumber
import Datable
import Transmission

public func squeeze_int(_ value: Int) -> Data
{
  var working = value
  var r = Data()

  if(working == 0)
  {
    r.append(0)
    return r
  }

  var negative: Bool = false
  if(working < 0)
  {
    negative = true
    working = -working
  }

  while(working != 0)
  {
    r.insert(UInt8(working & 0xFF), at: 0)
    working = working >> 8
  }

  var length: UInt8 = UInt8(r.count)

  if(negative)
  {
    length = length | 0x80
  }

  r.insert(length, at: 0)

  return r
}

public func squeeze_bigint(_ bint: BInt) -> Data
{
  var r: Data = Data()

  if let int = bint.asInt()
  {
    return squeeze_int(int)
  }

  let (negative, limbs) = bint.rawValue

  var lengthByte: UInt8 = UInt8(limbs.count)
  if(negative)
  {
    lengthByte = lengthByte | 0x80
  }

  r.append(lengthByte)

  let uint64s = limbs.map { UInt64(bitPattern: Int64($0)) }
  for uint64 in uint64s
  {
    r.append(uint64.data)
  }

  return r
}

public func squeeze_varint(_ i: Varint) -> Data
{
  switch i
  {
    case .int(let value):
      return squeeze_int(value)

    case .bint(let value):
      return squeeze_bigint(value)
  }
}

public func expand_int(_ data: Data) -> (Varint, Data)?
{
  if data.isEmpty
  {
    return nil
  }

  var lengthByte: UInt8 = data[0]

  if(lengthByte == 0)
  {
    let rest = Data(data[1...])
    return (.int(0), rest)
  }

  var negative: Bool = false
  let negativeByte = lengthByte & 0x80
  if (negativeByte & 0x80) == 0x80
  {
    negative = true
    lengthByte = lengthByte & 0x7F
  }
  let integerLength: Int = Int(lengthByte)

  if data.count < 1 + integerLength
  {
    return nil
  }

  let integerData = Data(data[1..<(integerLength+1)])
  let rest = Data(data[(integerLength+1)...])

  var bint = BInt(bytes: Array<UInt8>(integerData))
  if negative
  {
    bint = -bint
  }

  if let int = bint.asInt()
  {
    return (.int(int), rest)
  }
  else
  {
    return (.bint(bint), rest)
  }
}

public func expand_conn(_ conn: Connection) -> Varint?
{
  guard let bytes = conn.read(size: 1) else
  {
    return nil
  }

  var length = Int(bytes[0])

  if(length == 0)
  {
    return .int(0)
  }

  var negative: Bool = false
  if((length & 0x80) != 0)
  {
    length = length & 0x7F
    negative = true
  }

  guard let integerData = conn.read(size: length) else
  {
    return nil
  }

  var bint = BInt(bytes: integerData.array)
  if negative
  {
    bint = -bint
  }

  if let int = bint.asInt()
  {
    return .int(int)
  }
  else
  {
    return .bint(bint)
  }
}

public func squeeze_floating(_ floating: Floating) -> Data
{
  switch floating
  {
    case .float(let value):
      if(value == 0.0) // FIXME - add tolerance
      {
        return Data([0])
      }

      var result = Data()
      result.append(value.data)
      result.insert(UInt8(result.count), at: 0)
      return result

    case .double(let value):
      if(value == 0.0) // FIXME - add tolerance
      {
        return Data([0])
      }

      var result = Data()
      result.append(value.data)
      result.insert(UInt8(result.count), at: 0)
      return result
  }
}


public func expand_floating(_ data: Data) -> (Floating, Data)?
{
  if data.count == 0
  {
    return (.float(0), data)
  }

  let length: Int = Int(data[0])
  var rest = Data(data[1...])

  if(length == 0)
  {
    return (.float(0), rest)
  }

  switch length
  {
    case 4:
      let floatBytes = Data(rest[0..<4])
      rest = Data(rest[4...])

      guard let result = Float(data: floatBytes) else
      {
        return nil
      }
      return (.float(result), rest)

    case 8:
      let floatBytes = Data(rest[0..<8])
      rest = Data(rest[8...])

      guard let result = Double(data: floatBytes) else
      {
        return nil
      }
      return (.double(result), rest)

    default:
      return nil
  }
}

public func expand_conn_floating(_ conn: Connection) -> Floating?
{
  guard let lengthData = conn.read(size: 1) else
  {
    return nil
  }

  let length: Int = Int(lengthData[0])

  if(length == 0)
  {
    return .float(0.0)
  }

  guard let floatBytes = conn.read(size: length) else
  {
    return nil
  }

  switch length
  {
    case 4:
      guard let result = Float(data: floatBytes) else
      {
        return nil
      }
      return .float(result)

    case 8:
      guard let result = Double(data: floatBytes) else
      {
        return nil
      }
      return .double(result)

    default:
      return nil
  }
}

public func squeeze_ints(_ values: [Int]) -> Data
{
  if values.isEmpty
  {
    return Data([0])
  }

  var r: Data = Data()

  let size: Int = Int(values.count)
  let sizeBytes = squeeze_int(size)

  r.append(sizeBytes)

  for value in values
  {
    let valueBytes = squeeze_int(value)
    r.append(valueBytes)
  }

  return r
}

public func expand_ints(_ data: Data) -> ([Int], Data)?
{
  if data.isEmpty
  {
    return nil
  }

  var integers: [Int] = []

  guard let (varsize, rest) = expand_int(data) else
  {
    return nil
  }

  var working = rest
  switch varsize
  {
    case .int(let size):
      if size == 0
      {
        return ([], working)
      }

      for _ in 0..<size
      {
        guard let (varinteger, moreRest) = expand_int(working) else
        {
          return nil
        }
        working = moreRest

        switch varinteger
        {
          case .int(let integer):
            integers.append(integer)

          case .bint(_):
            return nil // FIXME
        }
      }

      return (integers, working)

    case .bint(_):
      return nil // FIXME
  }
}

public func squeeze_floats(_ values: [Float]) -> Data
{
  if values.isEmpty
  {
    return Data([0])
  }

  var r: Data = Data()

  let size: Int = Int(values.count)
  let sizeBytes: Data = squeeze_int(size)

  r.append(sizeBytes)

  for value in values
  {
    let valueBytes = squeeze_floating(.float(value))
    r.append(valueBytes)
  }

  return r;
}

public func expand_floats(_ data: Data) -> ([Float], Data)?
{
  if data.isEmpty
  {
    return nil
  }

  var results: [Float] = []

  guard let (varsize, rest) = expand_int(data) else
  {
    return nil
  }
  var working = rest
  switch varsize
  {
    case .int(let size):
      if size == 0
      {
        return ([], working)
      }

      for _ in 0..<size
      {
        guard let (floating, moreRest) = expand_floating(working) else
        {
          return nil
        }
        working = moreRest

        switch floating
        {
          case .float(let result):
            results.append(result)

          case .double(let result):
            results.append(Float(result))
        }
      }

      return (results, working)

    case .bint(_):
      return nil // FIXME
  }
}

public func squeeze_I(_ i: I) -> Data
{
  switch i
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

public func expand_I(_ data: Data, _ t: StorageType) -> (I, Data)?
{
  switch t
  {
    case .WORD:
      guard let (value, rest) = expand_int(data) else
      {
        return nil
      }

      switch value
      {
        case .int(let result):
          return (.word(result), rest)

        case .bint(_):
          return nil
      }

    case .WORD_ARRAY:
      guard let (value, rest) = expand_ints(data) else
      {
        return nil
      }

      return (.words(value), rest)

    case .FLOAT:
      guard let (floating, rest) = expand_floating(data) else
      {
        return nil
      }

      switch floating
      {
        case .float(let value):
          return (.float(value), rest)

        case .double(let value):
          return (.float(Float(value)), rest)
      }

    case .FLOAT_ARRAY:
      guard let (value, rest) = expand_floats(data) else
      {
        return nil
      }

      return (.floats(value), rest)

    case .MIXED_ARRAY:
      guard let (value, rest) = expand_mixed(data) else
      {
        return nil
      }

      return (.mixed(value), rest)

    default:
      return nil
  }
}

public func squeeze_storage(_ value: Storage) -> Data
{
  return value.data
}

public func expand_storage(_ data: Data) -> (Storage, Data)?
{
  if data.count < 3
  {
    return nil
  }

  let tb = data[0]
  let ob = data[1]
  var working = Data(data[2...])

  guard let tval = StorageType(rawValue: Int(tb)) else
  {
    return nil
  }

  guard let (value, moreRest) = expand_I(working, tval) else
  {
    return nil
  }
  working = moreRest

  let result = Storage(o: Int(ob), t: tval.rawValue, i: value)
  return (result, working)
}

public func squeeze_mixed(_ values: [Storage]) -> Data
{
  if values.isEmpty
  {
    return Data([0])
  }

  var r: Data = Data()

  let size: Int = Int(values.count)
  let sizeBytes: Data = squeeze_int(size)

  r.append(sizeBytes)

  for value in values
  {
    let valueBytes = value.data
    r.append(valueBytes)
  }

  return r;
}

public func expand_mixed(_ data: Data) -> ([Storage], Data)?
{
  if data.isEmpty
  {
    return nil
  }

  var results: [Storage] = []

  guard let (varsize, rest) = expand_int(data) else
  {
    return nil
  }
  var working = rest

  switch varsize
  {
    case .int(let size):
      if size == 0
      {
        return ([], working)
      }

      for _ in 0..<size
      {
        guard let (result, moreRest) = expand_storage(working) else
        {
          return nil
        }
        working = moreRest

        results.append(result)
      }

      return (results, working)

    case .bint(_):
      return nil // FIXME
  }
}
