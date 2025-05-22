import Testing
@testable import Ion

import BigNumber

enum TestError: Error
{
  case decodingError
  case mismatch
}

func test_word(_ x: Int) async throws -> Int
{
  let input = Word.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .word(let value):
      return value

    default:
      throw TestError.mismatch
  }
}

func test_bigint(_ x: BInt) async throws -> BInt
{
  let input = WordArray.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .word(let value):
      return BInt(value)

    case .words(let value):
      guard let bint = BInt(words: value) else
      {
        throw TestError.decodingError
      }

      return bint

    default:
      throw TestError.mismatch
  }
}

func test_float(_ x: Float) async throws -> Float
{
  let input = Float.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .float(let value):
      return value

    default:
      throw TestError.mismatch
  }
}

func test_words(_ x: [Int]) async throws -> [Int]
{
  let input = WordArray.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .words(let value):
      return value

    default:
      throw TestError.mismatch
  }
}

func test_floats(_ x: [Float]) async throws -> [Float]
{
  let input = FloatArray.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .floats(let value):
      return value

    default:
      throw TestError.mismatch
  }
}

func test_mixed(_ x: [Storage]) async throws -> [Storage]
{
  let input = MixedArray.make(x)
  let encoding = input.data
  guard let output = Storage(data: encoding) else
  {
    throw TestError.decodingError
  }

  switch output.i
  {
    case .mixed(let value):
      return value

    default:
      throw TestError.mismatch
  }
}

@Test func word() async throws
{
  #expect(try await test_word(0) == 0)
  #expect(try await test_word(1) == 1)
  #expect(try await test_word(-1) == -1)
  #expect(try await test_word(255) == 255)
  #expect(try await test_word(256) == 256)
  #expect(try await test_word(-256) == -256)
  #expect(try await test_word(2048) == 2048)
  #expect(try await test_word(-2048) == -2048)
  #expect(try await test_word(32768) == 32768)
  #expect(try await test_word(-32768) == -32768)
  #expect(try await test_word(8388608) == 8388608)
  #expect(try await test_word(-8388608) == -8388608)
  #expect(try await test_word(16777215) == 16777215)
  #expect(try await test_word(-16777215) == -16777215)
}

@Test func bint() async throws
{
  #expect(try await test_bigint(BInt("2147483648")!) == BInt("2147483648")!)
  #expect(try await test_bigint(BInt("-2147483648")!) == BInt("-2147483648")!)
  #expect(try await test_bigint(BInt("4294967295")!) == BInt("4294967295")!)
  #expect(try await test_bigint(BInt("-4294967295")!) == BInt("-4294967295")!)
  #expect(try await test_bigint(BInt("549755813888")!) == BInt("549755813888")!)
  #expect(try await test_bigint(BInt("-549755813888")!) == BInt("-549755813888")!)
  #expect(try await test_bigint(BInt("10000000000")!) == BInt("10000000000")!)
  #expect(try await test_bigint(BInt("-10000000000")!) == BInt("-10000000000")!)
  #expect(try await test_bigint(BInt("9223372036854775807")!) == BInt("9223372036854775807")!)
  #expect(try await test_bigint(BInt("-9223372036854775807")!) == BInt("-9223372036854775807")!)
}

@Test func float() async throws
{
  #expect(try await test_float(0.0) == 0.0)
  #expect(try await test_float(1.0) == 1.0)
  #expect(try await test_float(-1.0) == -1.0)
  #expect(try await test_float(1.0) == 1.0)
  #expect(try await test_float(-100.0) == -100.0)
}

@Test func words() async throws
{
  #expect(try await test_words([]) == [])
  #expect(try await test_words([0]) == [0])
  #expect(try await test_words([1]) == [1])
  #expect(try await test_words([-1]) == [-1])
  #expect(try await test_words([0, 1]) == [0, 1])
  #expect(try await test_words([1, 2]) == [1, 2])
  #expect(try await test_words([-1, 1]) == [-1, 1])
  #expect(try await test_words([256, 1024]) == [256, 1024])
  #expect(try await test_words([-256, -1024]) == [-256, -1024])
}

@Test func floats() async throws
{
  #expect(try await test_floats([]) == [])
  #expect(try await test_floats([0.0]) == [0.0])
  #expect(try await test_floats([1.0]) == [1.0])
  #expect(try await test_floats([-1.0]) == [-1.0])
  #expect(try await test_floats([0.0, 1.0]) == [0.0, 1.0])
  #expect(try await test_floats([1.0, 2.0]) == [1.0, 2.0])
  #expect(try await test_floats([-1.0, 1.0]) == [-1.0, 1.0])
  #expect(try await test_floats([256.0, 1024.0]) == [256.0, 1024.0])
  #expect(try await test_floats([-256.0, -1024.0]) == [-256.0, -1024.0])
}

@Test func mixed() async throws
{
  #expect(try await test_mixed([Word.make(0), Float.make(1.0)]) == [Word.make(0), Float.make(1.0)])
  #expect(try await test_mixed([Float.make(1.0), Word.make(1)]) == [Float.make(1.0), Word.make(1)])
  #expect(try await test_mixed([Word.make(0), WordArray.make([0])]) == [Word.make(0), WordArray.make([0])])
  #expect(try await test_mixed([Float.make(1.0), FloatArray.make([2.0])]) == [Float.make(1.0), FloatArray.make([2.0])])
  #expect(try await test_mixed([WordArray.make([0]), WordArray.make([0])]) == [WordArray.make([0]), WordArray.make([0])])
  #expect(try await test_mixed([WordArray.make([1]), WordArray.make([2])]) == [WordArray.make([1]), WordArray.make([2])])
  #expect(try await test_mixed([FloatArray.make([1.0]), FloatArray.make([2.0])]) == [FloatArray.make([1.0]), FloatArray.make([2.0])])
}
