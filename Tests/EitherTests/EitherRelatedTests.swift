import Either
import Testing

@Suite
struct EitherRelatedTests {

  // MARK: - Result Initializer

  @Suite
  struct ResultInitializer {
    @Test
    func resultFromLeftIsFailure() {
      let either = Either<TestError, Int>.left(.failed)
      let result = Result(either)
      switch result {
      case .failure(let error):
        #expect(error == .failed)
      case .success:
        Issue.record("Expected failure")
      }
    }

    @Test
    func resultFromRightIsSuccess() {
      let either = Either<TestError, Int>.right(42)
      let result = Result(either)
      switch result {
      case .success(let value):
        #expect(value == 42)
      case .failure:
        Issue.record("Expected success")
      }
    }
  }

  // MARK: - Either from Result

  @Suite
  struct EitherFromResult {
    @Test
    func eitherFromFailureIsLeft() {
      let result: Result<Int, TestError> = .failure(.failed)
      let either = Either(result)
      #expect(either.left == .failed)
      #expect(either.right == nil)
    }

    @Test
    func eitherFromSuccessIsRight() {
      let result: Result<Int, TestError> = .success(42)
      let either = Either(result)
      #expect(either.right == 42)
      #expect(either.left == nil)
    }

    @Test
    func roundTripResultToEitherToResult() {
      let original: Result<String, TestError> = .success("hello")
      let either = Either(original)
      let roundTripped = Result(either)

      switch (original, roundTripped) {
      case (.success(let a), .success(let b)):
        #expect(a == b)
      default:
        Issue.record("Round trip failed")
      }
    }

    @Test
    func roundTripEitherToResultToEither() {
      let original = Either<TestError, String>.right("hello")
      let result = Result(original)
      let roundTripped = Either(result)
      #expect(roundTripped == original)
    }
  }

  // MARK: - Optional orEmpty

  @Suite
  struct OptionalOrEmpty {
    @Test
    func someSequenceReturnsRight() {
      let optional: [Int]? = [1, 2, 3]
      let either = optional.orEmpty()
      #expect(either.right != nil)
      #expect(Array(either) == [1, 2, 3])
    }

    @Test
    func nilReturnsEmptyLeft() {
      let optional: [Int]? = nil
      let either = optional.orEmpty()
      #expect(either.left != nil)
      #expect(Array(either).isEmpty)
    }

    @Test
    func emptySequenceReturnsRight() {
      let optional: [Int]? = []
      let either = optional.orEmpty()
      #expect(either.right != nil)
      #expect(Array(either).isEmpty)
    }
  }

  // MARK: - Sequence separated

  @Suite
  struct Separated {
    @Test
    func separatesLeftsAndRights() {
      let sequence: [Either<String, Int>] = [
        .left("a"),
        .right(1),
        .left("b"),
        .right(2),
        .right(3),
      ]
      let (lefts, rights) = sequence.separated()
      #expect(lefts == ["a", "b"])
      #expect(rights == [1, 2, 3])
    }

    @Test
    func allLefts() {
      let sequence: [Either<String, Int>] = [
        .left("a"),
        .left("b"),
        .left("c"),
      ]
      let (lefts, rights) = sequence.separated()
      #expect(lefts == ["a", "b", "c"])
      #expect(rights.isEmpty)
    }

    @Test
    func allRights() {
      let sequence: [Either<String, Int>] = [
        .right(1),
        .right(2),
        .right(3),
      ]
      let (lefts, rights) = sequence.separated()
      #expect(lefts.isEmpty)
      #expect(rights == [1, 2, 3])
    }

    @Test
    func emptySequence() {
      let sequence: [Either<String, Int>] = []
      let (lefts, rights) = sequence.separated()
      #expect(lefts.isEmpty)
      #expect(rights.isEmpty)
    }
  }
}

