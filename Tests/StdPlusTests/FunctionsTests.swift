import StdPlus
import Testing

@Suite
struct FunctionsTests {
  enum TestError: Error {
    case failed
  }

  // MARK: - with

  @Suite
  struct With {
    @Test
    func withTransformsValue() {
      let result = with(42) { $0 * 2 }
      #expect(result == 84)
    }

    @Test
    func withReturnsTransformResult() {
      let result = with("hello") { $0.uppercased() }
      #expect(result == "HELLO")
    }

    @Test
    func withThrowingTransformSucceeds() throws {
      let result = try with(42) { value throws(TestError) -> Int in
        value * 2
      }
      #expect(result == 84)
    }

    @Test
    func withThrowingTransformThrows() {
      #expect(throws: TestError.self) {
        try with(42) { _ throws(TestError) -> Int in
          throw TestError.failed
        }
      }
    }

    @Test
    func asyncWithTransformsValue() async {
      let result = await with(42) { value async in
        value * 2
      }
      #expect(result == 84)
    }

    @Test
    func asyncWithThrowingTransformSucceeds() async throws {
      let result = try await with(42) { value async throws(TestError) -> Int in
        value * 2
      }
      #expect(result == 84)
    }

    @Test
    func asyncWithThrowingTransformThrows() async {
      await #expect(throws: TestError.self) {
        try await with(42) { _ async throws(TestError) -> Int in
          throw TestError.failed
        }
      }
    }
  }

  // MARK: - configure

  @Suite
  struct Configure {
    struct TestStruct {
      var value: Int = 0
      var name: String = ""
    }

    @Test
    func configureModifiesValue() {
      let result = configure(TestStruct()) { $0.value = 42 }
      #expect(result.value == 42)
    }

    @Test
    func configureModifiesMultipleProperties() {
      let result = configure(TestStruct()) {
        $0.value = 42
        $0.name = "test"
      }
      #expect(result.value == 42)
      #expect(result.name == "test")
    }

    @Test
    func configureThrowingSucceeds() throws {
      let result = try configure(TestStruct()) { value throws(TestError) in
        value.value = 42
      }
      #expect(result.value == 42)
    }

    @Test
    func configureThrowingThrows() {
      #expect(throws: TestError.self) {
        try configure(TestStruct()) { _ throws(TestError) in
          throw TestError.failed
        }
      }
    }

    @Test
    func configureWorksWithArray() {
      let result = configure([Int]()) {
        $0.append(1)
        $0.append(2)
        $0.append(3)
      }
      #expect(result == [1, 2, 3])
    }
  }

  // MARK: - catchAndReturn

  @Suite
  struct CatchAndReturn {
    @Test
    func catchAndReturnReturnsNilOnSuccess() {
      let error = catchAndReturn { () throws(TestError) in
        // Success, no throw
      }
      #expect(error == nil)
    }

    @Test
    func catchAndReturnReturnsErrorOnThrow() {
      let error = catchAndReturn { () throws(TestError) in
        throw TestError.failed
      }
      #expect(error == TestError.failed)
    }

    @Test
    func asyncCatchAndReturnReturnsNilOnSuccess() async {
      let error = await catchAndReturn { () async throws(TestError) in
        // Success, no throw
      }
      #expect(error == nil)
    }

    @Test
    func asyncCatchAndReturnReturnsErrorOnThrow() async {
      let error = await catchAndReturn { () async throws(TestError) in
        throw TestError.failed
      }
      #expect(error == TestError.failed)
    }
  }
}
