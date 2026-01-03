import Box
import Testing

@Suite
struct BoxTests {

  // MARK: - Box

  @Suite
  struct BoxType {
    @Test
    func boxStoresValue() {
      let box = Box(42)
      #expect(box.value == 42)
    }

    @Test
    func boxWorksWithStrings() {
      let box = Box("hello")
      #expect(box.value == "hello")
    }

    @Test
    func boxIsReferenceType() {
      let box1 = Box(42)
      let box2 = box1
      #expect(box1 === box2)
    }

    @Test
    func boxWorksWithStructs() {
      struct TestStruct: Equatable {
        var value: Int
      }
      let box = Box(TestStruct(value: 42))
      #expect(box.value == TestStruct(value: 42))
    }
  }

  // MARK: - MutexBox

  @Suite
  struct MutexBoxTests {
    @Test
    func mutexBoxStoresValue() {
      let box = MutexBox(42)
      #expect(box.value == 42)
    }

    @Test
    func mutexBoxWithLockModifiesValue() {
      let box = MutexBox(42)
      box.withLock { $0 += 1 }
      #expect(box.value == 43)
    }

    @Test
    func mutexBoxWithLockReturnsResult() {
      let box = MutexBox(42)
      let result = box.withLock { $0 * 2 }
      #expect(result == 84)
    }

    @Test
    func mutexBoxSetValueReturnsOldValue() {
      let box = MutexBox(42)
      let old = box.setValue(100)
      #expect(old == 42)
      #expect(box.value == 100)
    }

    @Test
    func mutexBoxTakeRemovesOptionalValue() {
      let box = MutexBox<Int?>(42)
      let taken = box.take()
      #expect(taken == 42)
      #expect(box.value == nil)
    }

    @Test
    func mutexBoxTakeOnNilReturnsNil() {
      let box = MutexBox<Int?>(nil)
      let taken = box.take()
      #expect(taken == nil)
    }

    @Test
    func mutexBoxWithLockThrowingSucceeds() throws {
      enum TestError: Error { case failed }
      let box = MutexBox(42)
      let result = try box.withLock { value throws(TestError) -> Int in
        value * 2
      }
      #expect(result == 84)
    }

    @Test
    func mutexBoxWithLockThrowingThrows() {
      enum TestError: Error { case failed }
      let box = MutexBox(42)
      #expect(throws: TestError.self) {
        try box.withLock { _ throws(TestError) -> Int in
          throw TestError.failed
        }
      }
    }
  }
}
