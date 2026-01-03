import StdPlus
import Testing

@Suite
struct SequenceTests {

  // MARK: - only

  @Suite
  struct Only {
    @Test
    func singleElementReturnsElement() {
      let array = [42]
      #expect(array.only == 42)
    }

    @Test
    func emptySequenceReturnsNil() {
      let array: [Int] = []
      #expect(array.only == nil)
    }

    @Test
    func multipleElementsReturnsNil() {
      let array = [1, 2, 3]
      #expect(array.only == nil)
    }

    @Test
    func twoElementsReturnsNil() {
      let array = [1, 2]
      #expect(array.only == nil)
    }

    @Test
    func worksWithStrings() {
      let array = ["hello"]
      #expect(array.only == "hello")
    }

    @Test
    func worksWithFilteredSequence() {
      let array = [1, 2, 3, 4, 5]
      let filtered = array.filter { $0 == 3 }
      #expect(filtered.only == 3)
    }

    @Test
    func worksWithSet() {
      let set: Set = [42]
      #expect(set.only == 42)
    }

    @Test
    func multipleMatchingFilterReturnsNil() {
      let array = [1, 2, 2, 3]
      let filtered = array.filter { $0 == 2 }
      #expect(filtered.only == nil)
    }

    @Test
    func lazySequenceWorks() {
      let range = 1...1
      #expect(range.lazy.only == 1)
    }
  }
}
