import StdPlus
import Testing

@Suite
public struct OptionalTests {
  enum CustomError: Error {
    case notFound
  }

  @Suite
  struct OptionalOrThrow {
    @Test
    func orThrowWithValueReturnsValue() throws {
      let optional: Int? = 42
      let result = try optional.orThrow(CustomError.notFound)
      #expect(result == 42)
    }

    @Test
    func orThrowWithNilThrowsProvidedError() {
      let optional: Int? = nil
      #expect(throws: CustomError.self) {
        try optional.orThrow(CustomError.notFound)
      }
    }

    @Test
    func orThrowWithValueReturnsValueDefaultError() throws {
      let optional: String? = "hello"
      let result = try optional.orThrow()
      #expect(result == "hello")
    }

    @Test
    func orThrowWithNilThrowsUnwrapError() {
      let optional: String? = nil
      #expect(throws: UnwrapError<String>.self) {
        try optional.orThrow()
      }
    }

    @Test
    func unwrapErrorContainsCorrectTypeForCustomType() throws {
      struct MyType {}
      let optional: MyType? = nil
      let error = try #require(throws: UnwrapError<MyType>.self) {
        try optional.orThrow()
      }
      #expect(String(describing: error.type) == "MyType")
    }

    @Test
    func orThrowWithLazyErrorOnlyEvaluatesOnNil() throws {
      var errorCreated = false
      let optional: Int? = 42
      _ = try optional.orThrow({
        errorCreated = true
        return CustomError.notFound
      }())
      #expect(!errorCreated)
    }

    @Test
    func orThrowChainedOnOptionalBinding() throws {
      let dict = ["key": 42]
      let value = try dict["key"].orThrow(CustomError.notFound)
      #expect(value == 42)
    }

    @Test
    func orThrowWithMissingDictionaryKey() {
      let dict = ["key": 42]
      #expect(throws: CustomError.self) {
        try dict["missing"].orThrow(CustomError.notFound)
      }
    }
  }

  // MARK: - Filter

  @Suite
  struct Filter {
    @Test
    func filterKeepsValueWhenPredicateTrue() {
      let optional: Int? = 42
      let filtered = optional.filter { $0 > 10 }
      #expect(filtered == 42)
    }

    @Test
    func filterRemovesValueWhenPredicateFalse() {
      let optional: Int? = 5
      let filtered = optional.filter { $0 > 10 }
      #expect(filtered == nil)
    }

    @Test
    func filterOnNilReturnsNil() {
      let optional: Int? = nil
      let filtered = optional.filter { $0 > 10 }
      #expect(filtered == nil)
    }

    @Test
    func filterWithThrowingPredicateSucceeds() throws {
      let optional: Int? = 42
      let filtered = try optional.filter { value throws(CustomError) -> Bool in
        value > 10
      }
      #expect(filtered == 42)
    }

    @Test
    func filterWithThrowingPredicateThrows() {
      let optional: Int? = 42
      #expect(throws: CustomError.self) {
        try optional.filter { _ throws(CustomError) -> Bool in
          throw CustomError.notFound
        }
      }
    }

    @Test
    func filterOnNilDoesNotCallPredicate() throws {
      var predicateCalled = false
      let optional: Int? = nil
      _ = optional.filter { _ in
        predicateCalled = true
        return true
      }
      #expect(!predicateCalled)
    }

    @Test
    func filterWithStringPredicate() {
      let optional: String? = "hello"
      let filtered = optional.filter { $0.count > 3 }
      #expect(filtered == "hello")
    }

    @Test
    func filterWithStringPredicateFails() {
      let optional: String? = "hi"
      let filtered = optional.filter { $0.count > 3 }
      #expect(filtered == nil)
    }

    @Test
    func filterChaining() {
      let optional: Int? = 42
      let result = optional
        .filter { $0 > 10 }
        .filter { $0 < 100 }
        .filter { $0 % 2 == 0 }
      #expect(result == 42)
    }

    @Test
    func filterChainingWithFailure() {
      let optional: Int? = 42
      let result = optional
        .filter { $0 > 10 }
        .filter { $0 > 100 }  // This fails
        .filter { $0 % 2 == 0 }
      #expect(result == nil)
    }
  }

  // MARK: - TakeOrThrow

  @Suite
  struct TakeOrThrow {
    @Test
    func takeOrThrowWithValueReturnsValueAndSetsToNil() throws {
      var optional: Int? = 42
      let result = try optional.takeOrThrow(CustomError.notFound)
      #expect(result == 42)
      #expect(optional == nil)
    }

    @Test
    func takeOrThrowWithNilThrowsProvidedError() {
      var optional: Int? = nil
      #expect(throws: CustomError.self) {
        try optional.takeOrThrow(CustomError.notFound)
      }
    }

    @Test
    func takeOrThrowWithValueReturnsValueDefaultError() throws {
      var optional: String? = "hello"
      let result = try optional.takeOrThrow()
      #expect(result == "hello")
      #expect(optional == nil)
    }

    @Test
    func takeOrThrowWithNilThrowsUnwrapError() {
      var optional: String? = nil
      #expect(throws: UnwrapError<String>.self) {
        try optional.takeOrThrow()
      }
    }
  }

  // MARK: - Async Map

  @Suite
  struct AsyncMap {
    @Test
    func asyncMapWithValueTransforms() async throws {
      let optional: Int? = 42
      let result = await optional.map { value async -> String in
        "\(value)"
      }
      #expect(result == "42")
    }

    @Test
    func asyncMapWithNilReturnsNil() async {
      let optional: Int? = nil
      let result = await optional.map { value async -> String in
        "\(value)"
      }
      #expect(result == nil)
    }

    @Test
    func asyncMapWithThrowingTransformSucceeds() async throws {
      let optional: Int? = 42
      let result = try await optional.map { value async throws(CustomError) -> String in
        "\(value)"
      }
      #expect(result == "42")
    }

    @Test
    func asyncMapWithThrowingTransformThrows() async {
      let optional: Int? = 42
      await #expect(throws: CustomError.self) {
        try await optional.map { _ async throws(CustomError) -> String in
          throw CustomError.notFound
        }
      }
    }

    @Test
    func asyncMapOnNilDoesNotCallTransform() async {
      var transformCalled = false
      let optional: Int? = nil
      _ = await optional.map { value async -> String in
        transformCalled = true
        return "\(value)"
      }
      #expect(!transformCalled)
    }
  }

  // MARK: - Async FlatMap

  @Suite
  struct AsyncFlatMap {
    @Test
    func asyncFlatMapWithValueAndSomeResult() async throws {
      let optional: Int? = 42
      let result = await optional.flatMap { value async -> String? in
        "\(value)"
      }
      #expect(result == "42")
    }

    @Test
    func asyncFlatMapWithValueAndNilResult() async {
      let optional: Int? = 42
      let result = await optional.flatMap { _ async -> String? in
        nil
      }
      #expect(result == nil)
    }

    @Test
    func asyncFlatMapWithNilReturnsNil() async {
      let optional: Int? = nil
      let result = await optional.flatMap { value async -> String? in
        "\(value)"
      }
      #expect(result == nil)
    }

    @Test
    func asyncFlatMapWithThrowingTransformSucceeds() async throws {
      let optional: Int? = 42
      let result = try await optional.flatMap { value async throws(CustomError) -> String? in
        "\(value)"
      }
      #expect(result == "42")
    }

    @Test
    func asyncFlatMapWithThrowingTransformThrows() async {
      let optional: Int? = 42
      await #expect(throws: CustomError.self) {
        try await optional.flatMap { _ async throws(CustomError) -> String? in
          throw CustomError.notFound
        }
      }
    }

    @Test
    func asyncFlatMapOnNilDoesNotCallTransform() async {
      var transformCalled = false
      let optional: Int? = nil
      _ = await optional.flatMap { value async -> String? in
        transformCalled = true
        return "\(value)"
      }
      #expect(!transformCalled)
    }
  }
}
