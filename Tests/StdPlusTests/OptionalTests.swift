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
      #expect(throws: UnwrapError.self) {
        try optional.orThrow()
      }
    }

    @Test
    func unwrapErrorContainsCorrectType() throws {
      let optional: Int? = nil
      let error = try #require(throws: UnwrapError.self) {
        try optional.orThrow()
      }
      #expect(error.wrappedType is Int.Type)
    }

    @Test
    func unwrapErrorContainsCorrectTypeForCustomType() throws {
      struct MyType {}
      let optional: MyType? = nil
      let error = try #require(throws: UnwrapError.self) {
        try optional.orThrow()
      }
      #expect(String(describing: error.wrappedType) == "MyType")
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
}
