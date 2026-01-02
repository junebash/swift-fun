import StdPlus
import Testing

@Suite
struct CollectionTests {
  @Suite
  struct CollectionNonEmpty {
    @Test
    func nonEmptyArrayReturnsItself() {
      let array = [1, 2, 3]
      #expect(array.nonEmpty == [1, 2, 3])
    }

    @Test
    func emptyArrayReturnsNil() {
      let array: [Int] = []
      #expect(array.nonEmpty == nil)
    }

    @Test
    func nonEmptyStringReturnsItself() {
      let string = "hello"
      #expect(string.nonEmpty == "hello")
    }

    @Test
    func emptyStringReturnsNil() {
      let string = ""
      #expect(string.nonEmpty == nil)
    }

    @Test
    func nonEmptySetReturnsItself() {
      let set: Set<Int> = [1, 2, 3]
      #expect(set.nonEmpty == [1, 2, 3])
    }

    @Test
    func emptySetReturnsNil() {
      let set: Set<Int> = []
      #expect(set.nonEmpty == nil)
    }

    @Test
    func nonEmptyDictionaryReturnsItself() {
      let dict = ["a": 1, "b": 2]
      #expect(dict.nonEmpty == ["a": 1, "b": 2])
    }

    @Test
    func emptyDictionaryReturnsNil() {
      let dict: [String: Int] = [:]
      #expect(dict.nonEmpty == nil)
    }

    @Test
    func singleElementArrayReturnsItself() {
      let array = [42]
      #expect(array.nonEmpty == [42])
    }

    @Test
    func worksWithOptionalChaining() {
      let maybeArray: [Int]? = [1, 2, 3]
      #expect(maybeArray?.nonEmpty == [1, 2, 3])

      let emptyMaybeArray: [Int]? = []
      #expect(emptyMaybeArray?.nonEmpty == nil)

      let nilArray: [Int]? = nil
      #expect(nilArray?.nonEmpty == nil)
    }
  }
}
