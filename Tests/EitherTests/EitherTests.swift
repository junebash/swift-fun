import Testing

@testable import Either

@Suite
struct EitherTests {

  // MARK: - Basic Construction

  @Suite
  struct Construction {
    @Test
    func leftCase() {
      let either = Either<Int, String>.left(42)
      #expect(either.left == 42)
      #expect(either.right == nil)
    }

    @Test
    func rightCase() {
      let either = Either<Int, String>.right("hello")
      #expect(either.left == nil)
      #expect(either.right == "hello")
    }

    @Test
    func initWithLeft() {
      let either = Either<Int, String>(left: 42)
      #expect(either.left == 42)
      #expect(either.right == nil)
    }

    @Test
    func initWithRight() {
      let either = Either<Int, String>(right: "hello")
      #expect(either.left == nil)
      #expect(either.right == "hello")
    }
  }

  // MARK: - Map

  @Suite
  struct Map {
    @Test
    func mapTransformsRightValue() {
      let either = Either<Int, String>.right("hello")
      let mapped = either.map { $0.uppercased() }
      #expect(mapped.right == "HELLO")
      #expect(mapped.left == nil)
    }

    @Test
    func mapPreservesLeftValue() {
      let either = Either<Int, String>.left(42)
      let mapped = either.map { $0.uppercased() }
      #expect(mapped.left == 42)
      #expect(mapped.right == nil)
    }

    @Test
    func mapWithThrowingTransformSucceeds() throws {
      let either = Either<Int, String>.right("hello")
      let mapped = try either.map { value throws(TestError) -> String in
        value.uppercased()
      }
      #expect(mapped.right == "HELLO")
    }

    @Test
    func mapWithThrowingTransformThrows() {
      let either = Either<Int, String>.right("hello")
      #expect(throws: TestError.self) {
        try either.map { _ throws(TestError) -> String in
          throw TestError.failed
        }
      }
    }

    @Test
    func mapWithThrowingTransformOnLeftDoesNotThrow() throws {
      let either = Either<Int, String>.left(42)
      let mapped = try either.map { _ throws(TestError) -> String in
        throw TestError.failed
      }
      #expect(mapped.left == 42)
    }
  }

  // MARK: - MapLeft

  @Suite
  struct MapLeft {
    @Test
    func mapLeftTransformsLeftValue() {
      let either = Either<Int, String>.left(42)
      let mapped = either.mapLeft { $0 * 2 }
      #expect(mapped.left == 84)
      #expect(mapped.right == nil)
    }

    @Test
    func mapLeftPreservesRightValue() {
      let either = Either<Int, String>.right("hello")
      let mapped = either.mapLeft { $0 * 2 }
      #expect(mapped.right == "hello")
      #expect(mapped.left == nil)
    }

    @Test
    func mapLeftWithThrowingTransformSucceeds() throws {
      let either = Either<Int, String>.left(42)
      let mapped = try either.mapLeft { value throws(TestError) -> Int in
        value * 2
      }
      #expect(mapped.left == 84)
    }

    @Test
    func mapLeftWithThrowingTransformThrows() {
      let either = Either<Int, String>.left(42)
      #expect(throws: TestError.self) {
        try either.mapLeft { _ throws(TestError) -> Int in
          throw TestError.failed
        }
      }
    }

    @Test
    func mapLeftWithThrowingTransformOnRightDoesNotThrow() throws {
      let either = Either<Int, String>.right("hello")
      let mapped = try either.mapLeft { _ throws(TestError) -> Int in
        throw TestError.failed
      }
      #expect(mapped.right == "hello")
    }
  }

  // MARK: - Bimap

  @Suite
  struct Bimap {
    @Test
    func bimapTransformsLeftValue() {
      let either = Either<Int, String>.left(42)
      let mapped = either.bimap(left: { $0 * 2 }, right: { $0.uppercased() })
      #expect(mapped.left == 84)
      #expect(mapped.right == nil)
    }

    @Test
    func bimapTransformsRightValue() {
      let either = Either<Int, String>.right("hello")
      let mapped = either.bimap(left: { $0 * 2 }, right: { $0.uppercased() })
      #expect(mapped.right == "HELLO")
      #expect(mapped.left == nil)
    }

    @Test
    func bimapWithThrowingLeftTransformThrows() {
      let either = Either<Int, String>.left(42)
      #expect(throws: TestError.self) {
        _ = try either.bimap(
          left: { _ in throw TestError.failed },
          right: { $0.uppercased() }
        )
      }
    }

    @Test
    func bimapWithThrowingRightTransformThrows() {
      let either = Either<Int, String>.right("hello")
      #expect(throws: TestError.self) {
        _ = try either.bimap(
          left: { $0 * 2 },
          right: { _ in throw TestError.failed }
        )
      }
    }

    @Test
    func bimapChangesTypes() {
      let either = Either<Int, String>.left(42)
      let mapped: Either<String, Int> = either.bimap(
        left: { String($0) },
        right: { $0.count }
      )
      #expect(mapped.left == "42")
    }
  }

  // MARK: - Fold

  @Suite
  struct Fold {
    @Test
    func foldLeftValue() {
      let either = Either<Int, String>.left(42)
      let result = either.fold(left: { $0 * 2 }, right: { $0.count })
      #expect(result == 84)
    }

    @Test
    func foldRightValue() {
      let either = Either<Int, String>.right("hello")
      let result = either.fold(left: { $0 * 2 }, right: { $0.count })
      #expect(result == 5)
    }

    @Test
    func foldWithThrowingLeftTransformThrows() {
      let either = Either<Int, String>.left(42)
      #expect(throws: TestError.self) {
        _ = try either.fold(
          left: { _ in throw TestError.failed },
          right: { $0.count }
        )
      }
    }

    @Test
    func foldWithThrowingRightTransformThrows() {
      let either = Either<Int, String>.right("hello")
      #expect(throws: TestError.self) {
        _ = try either.fold(
          left: { $0 * 2 },
          right: { _ in throw TestError.failed }
        )
      }
    }

    @Test
    func foldToString() {
      let leftEither = Either<Int, Double>.left(42)
      let rightEither = Either<Int, Double>.right(3.14)

      let leftResult = leftEither.fold(
        left: { "Int: \($0)" },
        right: { "Double: \($0)" }
      )
      let rightResult = rightEither.fold(
        left: { "Int: \($0)" },
        right: { "Double: \($0)" }
      )

      #expect(leftResult == "Int: 42")
      #expect(rightResult == "Double: 3.14")
    }
  }

  // MARK: - Swapped

  @Suite
  struct Swapped {
    @Test
    func swappedLeftBecomesRight() {
      let either = Either<Int, String>.left(42)
      let swapped = either.swapped
      #expect(swapped.right == 42)
      #expect(swapped.left == nil)
    }

    @Test
    func swappedRightBecomesLeft() {
      let either = Either<Int, String>.right("hello")
      let swapped = either.swapped
      #expect(swapped.left == "hello")
      #expect(swapped.right == nil)
    }

    @Test
    func doubleSwapRestoresOriginal() {
      let either = Either<Int, String>.left(42)
      let doubleSwapped = either.swapped.swapped
      #expect(doubleSwapped == either)
    }
  }

  // MARK: - FlatMap

  @Suite
  struct FlatMap {
    @Test
    func flatMapTransformsRightToRight() {
      let either = Either<Int, String>.right("hello")
      let flatMapped = either.flatMap { Either<Int, Int>.right($0.count) }
      #expect(flatMapped.right == 5)
      #expect(flatMapped.left == nil)
    }

    @Test
    func flatMapTransformsRightToLeft() {
      let either = Either<Int, String>.right("hello")
      let flatMapped = either.flatMap { _ in Either<Int, Int>.left(99) }
      #expect(flatMapped.left == 99)
      #expect(flatMapped.right == nil)
    }

    @Test
    func flatMapPreservesLeftValue() {
      let either = Either<Int, String>.left(42)
      let flatMapped = either.flatMap { Either<Int, Int>.right($0.count) }
      #expect(flatMapped.left == 42)
      #expect(flatMapped.right == nil)
    }

    @Test
    func flatMapWithThrowingTransformSucceeds() throws {
      let either = Either<Int, String>.right("hello")
      let flatMapped = try either.flatMap { value throws(TestError) in
        Either<Int, Int>.right(value.count)
      }
      #expect(flatMapped.right == 5)
    }

    @Test
    func flatMapWithThrowingTransformThrows() {
      let either = Either<Int, String>.right("hello")
      #expect(throws: TestError.self) {
        try either.flatMap { _ throws(TestError) -> Either<Int, Int> in
          throw TestError.failed
        }
      }
    }

    @Test
    func flatMapWithThrowingTransformOnLeftDoesNotThrow() throws {
      let either = Either<Int, String>.left(42)
      let flatMapped = try either.flatMap { _ throws(TestError) -> Either<Int, Int> in
        throw TestError.failed
      }
      #expect(flatMapped.left == 42)
    }
  }

  // MARK: - Equatable

  @Suite
  struct Equatable {
    @Test
    func leftValuesAreEqual() {
      let either1 = Either<Int, String>.left(42)
      let either2 = Either<Int, String>.left(42)
      #expect(either1 == either2)
    }

    @Test
    func rightValuesAreEqual() {
      let either1 = Either<Int, String>.right("hello")
      let either2 = Either<Int, String>.right("hello")
      #expect(either1 == either2)
    }

    @Test
    func differentLeftValuesAreNotEqual() {
      let either1 = Either<Int, String>.left(42)
      let either2 = Either<Int, String>.left(99)
      #expect(either1 != either2)
    }

    @Test
    func differentRightValuesAreNotEqual() {
      let either1 = Either<Int, String>.right("hello")
      let either2 = Either<Int, String>.right("world")
      #expect(either1 != either2)
    }

    @Test
    func leftAndRightAreNotEqual() {
      let either1 = Either<Int, Int>.left(42)
      let either2 = Either<Int, Int>.right(42)
      #expect(either1 != either2)
    }
  }

  // MARK: - Hashable

  @Suite
  struct Hashable {
    @Test
    func equalValuesHaveSameHash() {
      let either1 = Either<Int, String>.left(42)
      let either2 = Either<Int, String>.left(42)
      #expect(either1.hashValue == either2.hashValue)
    }

    @Test
    func canBeUsedInSet() {
      let set: Set<Either<Int, String>> = [
        .left(1),
        .left(2),
        .right("a"),
        .right("b"),
        .left(1),  // duplicate
      ]
      #expect(set.count == 4)
    }

    @Test
    func canBeUsedAsDictionaryKey() {
      var dict: [Either<Int, String>: String] = [:]
      dict[.left(1)] = "one"
      dict[.right("a")] = "letter a"
      #expect(dict[.left(1)] == "one")
      #expect(dict[.right("a")] == "letter a")
      #expect(dict[.left(2)] == nil)
    }
  }

  // MARK: - Sequence Conformance

  @Suite
  struct SequenceConformance {
    @Test
    func leftSequenceIterates() {
      let either = Either<[Int], [Int]>.left([1, 2, 3])
      let result = Array(either)
      #expect(result == [1, 2, 3])
    }

    @Test
    func rightSequenceIterates() {
      let either = Either<[Int], [Int]>.right([4, 5, 6])
      let result = Array(either)
      #expect(result == [4, 5, 6])
    }

    @Test
    func emptyLeftSequence() {
      let either = Either<[Int], [Int]>.left([])
      let result = Array(either)
      #expect(result.isEmpty)
    }

    @Test
    func emptyRightSequence() {
      let either = Either<[Int], [Int]>.right([])
      let result = Array(either)
      #expect(result.isEmpty)
    }

    @Test
    func canUseForIn() {
      let either = Either<[Int], Set<Int>>.right([1, 2, 3])
      var sum = 0
      for value in either {
        sum += value
      }
      #expect(sum == 6)
    }

    @Test
    func worksWithDifferentSequenceTypes() {
      let either = Either<ClosedRange<Int>, [Int]>.left(1...3)
      let result = Array(either)
      #expect(result == [1, 2, 3])
    }
  }
}

// MARK: - Test Helpers

enum TestError: Error, Equatable {
  case failed
}
