import SequenceBuilder
import Testing

@Suite
struct Chain2SequenceTests {

  // MARK: - Basic Chaining

  @Suite
  struct BasicChaining {
    @Test
    func chainTwoArrays() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      #expect(Array(chained) == [1, 2, 3, 4, 5, 6])
    }

    @Test
    func chainArrayAndRange() {
      let chained = chain([1, 2], 3...5)
      #expect(Array(chained) == [1, 2, 3, 4, 5])
    }

    @Test
    func chainRangeAndArray() {
      let chained = chain(1...2, [3, 4, 5])
      #expect(Array(chained) == [1, 2, 3, 4, 5])
    }

    @Test
    func chainEmptyAndNonEmpty() {
      let chained = chain([Int](), [1, 2, 3])
      #expect(Array(chained) == [1, 2, 3])
    }

    @Test
    func chainNonEmptyAndEmpty() {
      let chained = chain([1, 2, 3], [Int]())
      #expect(Array(chained) == [1, 2, 3])
    }

    @Test
    func chainTwoEmptySequences() {
      let chained = chain([Int](), [Int]())
      #expect(Array(chained).isEmpty)
    }

    @Test
    func chainSingleElementSequences() {
      let chained = chain([1], [2])
      #expect(Array(chained) == [1, 2])
    }

    @Test
    func chainStrings() {
      let chained = chain("abc", "def")
      #expect(String(chained) == "abcdef")
    }
  }

  // MARK: - Collection Conformance

  @Suite
  struct CollectionConformance {
    @Test
    func countIsCorrect() {
      let chained = chain([1, 2, 3], [4, 5])
      #expect(chained.count == 5)
    }

    @Test
    func countWithEmptyFirst() {
      let chained = chain([Int](), [1, 2, 3])
      #expect(chained.count == 3)
    }

    @Test
    func countWithEmptySecond() {
      let chained = chain([1, 2, 3], [Int]())
      #expect(chained.count == 3)
    }

    @Test
    func countWithBothEmpty() {
      let chained = chain([Int](), [Int]())
      #expect(chained.count == 0)
    }

    @Test
    func subscriptFromFirstCollection() {
      let chained = chain([10, 20, 30], [40, 50])
      let index = chained.startIndex
      #expect(chained[index] == 10)
    }

    @Test
    func subscriptFromSecondCollection() {
      let chained = chain([10, 20], [30, 40, 50])
      let index = chained.index(chained.startIndex, offsetBy: 3)
      #expect(chained[index] == 40)
    }

    @Test
    func subscriptAtBoundary() {
      let chained = chain([10, 20], [30, 40])
      let index = chained.index(chained.startIndex, offsetBy: 2)
      #expect(chained[index] == 30)
    }

    @Test
    func isEmptyWhenBothEmpty() {
      let chained = chain([Int](), [Int]())
      #expect(chained.isEmpty)
    }

    @Test
    func isNotEmptyWhenFirstHasElements() {
      let chained = chain([1], [Int]())
      #expect(!chained.isEmpty)
    }

    @Test
    func isNotEmptyWhenSecondHasElements() {
      let chained = chain([Int](), [1])
      #expect(!chained.isEmpty)
    }

    @Test
    func firstElement() {
      let chained = chain([10, 20], [30, 40])
      #expect(chained.first == 10)
    }

    @Test
    func firstElementWhenFirstEmpty() {
      let chained = chain([Int](), [30, 40])
      #expect(chained.first == 30)
    }

    @Test
    func firstElementWhenBothEmpty() {
      let chained = chain([Int](), [Int]())
      #expect(chained.first == nil)
    }
  }

  // MARK: - Index Operations

  @Suite
  struct IndexOperations {
    @Test
    func indexAfterInFirstCollection() {
      let chained = chain([1, 2, 3], [4, 5])
      let start = chained.startIndex
      let next = chained.index(after: start)
      #expect(chained[next] == 2)
    }

    @Test
    func indexAfterCrossesToSecondCollection() {
      let chained = chain([1, 2], [3, 4])
      var index = chained.startIndex
      index = chained.index(after: index)  // points to 2
      index = chained.index(after: index)  // should point to 3
      #expect(chained[index] == 3)
    }

    @Test
    func indexOffsetByPositive() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let index = chained.index(chained.startIndex, offsetBy: 4)
      #expect(chained[index] == 5)
    }

    @Test
    func indexOffsetByZero() {
      let chained = chain([1, 2], [3, 4])
      let index = chained.index(chained.startIndex, offsetBy: 0)
      #expect(chained[index] == 1)
    }

    @Test
    func distanceWithinFirstCollection() {
      let chained = chain([1, 2, 3], [4, 5])
      let start = chained.startIndex
      let end = chained.index(start, offsetBy: 2)
      #expect(chained.distance(from: start, to: end) == 2)
    }

    @Test
    func distanceAcrossCollections() {
      let chained = chain([1, 2], [3, 4, 5])
      let start = chained.startIndex
      let end = chained.index(start, offsetBy: 4)
      #expect(chained.distance(from: start, to: end) == 4)
    }

    @Test
    func distanceToEnd() {
      let chained = chain([1, 2], [3, 4])
      let start = chained.startIndex
      let end = chained.endIndex
      #expect(chained.distance(from: start, to: end) == 4)
    }
  }

  // MARK: - BidirectionalCollection

  @Suite
  struct BidirectionalCollectionConformance {
    @Test
    func indexBeforeInSecondCollection() {
      let chained = chain([1, 2], [3, 4])
      let end = chained.endIndex
      let beforeEnd = chained.index(before: end)
      #expect(chained[beforeEnd] == 4)
    }

    @Test
    func indexBeforeCrossesToFirstCollection() {
      let chained = chain([1, 2], [3, 4])
      var index = chained.endIndex
      index = chained.index(before: index)  // points to 4
      index = chained.index(before: index)  // points to 3
      index = chained.index(before: index)  // should point to 2
      #expect(chained[index] == 2)
    }

    @Test
    func lastElement() {
      let chained = chain([1, 2], [3, 4])
      #expect(chained.last == 4)
    }

    @Test
    func lastElementWhenSecondEmpty() {
      let chained = chain([1, 2], [Int]())
      #expect(chained.last == 2)
    }

    @Test
    func reversedIteration() {
      let chained = chain([1, 2], [3, 4])
      let reversed = Array(chained.reversed())
      #expect(reversed == [4, 3, 2, 1])
    }

    @Test
    func indexOffsetByNegative() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let end = chained.endIndex
      let index = chained.index(end, offsetBy: -2)
      #expect(chained[index] == 5)
    }

    @Test
    func indexOffsetByNegativeAcrossCollections() {
      let chained = chain([1, 2, 3], [4, 5])
      let end = chained.endIndex
      let index = chained.index(end, offsetBy: -4)
      #expect(chained[index] == 2)
    }
  }

  // MARK: - RandomAccessCollection

  @Suite
  struct RandomAccessCollectionConformance {
    @Test
    func randomAccessIndexing() {
      let chained = chain([1, 2, 3, 4, 5], [6, 7, 8, 9, 10])
      let index = chained.index(chained.startIndex, offsetBy: 7)
      #expect(chained[index] == 8)
    }

    @Test
    func randomAccessDistanceCalculation() {
      let chained = chain(Array(1...100), Array(101...200))
      let start = chained.index(chained.startIndex, offsetBy: 50)
      let end = chained.index(chained.startIndex, offsetBy: 150)
      #expect(chained.distance(from: start, to: end) == 100)
    }

    @Test
    func prefixOperation() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let prefix = Array(chained.prefix(4))
      #expect(prefix == [1, 2, 3, 4])
    }

    @Test
    func suffixOperation() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let suffix = Array(chained.suffix(4))
      #expect(suffix == [3, 4, 5, 6])
    }

    @Test
    func dropFirstOperation() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let dropped = Array(chained.dropFirst(2))
      #expect(dropped == [3, 4, 5, 6])
    }

    @Test
    func dropLastOperation() {
      let chained = chain([1, 2, 3], [4, 5, 6])
      let dropped = Array(chained.dropLast(2))
      #expect(dropped == [1, 2, 3, 4])
    }
  }

  // MARK: - Index Comparison

  @Suite
  struct IndexComparison {
    @Test
    func indicesInFirstCollectionCompareCorrectly() {
      let chained = chain([1, 2, 3], [4, 5])
      let i1 = chained.startIndex
      let i2 = chained.index(after: i1)
      #expect(i1 < i2)
    }

    @Test
    func indicesInSecondCollectionCompareCorrectly() {
      let chained = chain([1, 2], [3, 4, 5])
      let i1 = chained.index(chained.startIndex, offsetBy: 2)
      let i2 = chained.index(chained.startIndex, offsetBy: 3)
      #expect(i1 < i2)
    }

    @Test
    func firstCollectionIndexLessThanSecond() {
      let chained = chain([1, 2], [3, 4])
      let i1 = chained.startIndex  // first collection
      let i2 = chained.index(chained.startIndex, offsetBy: 2)  // second collection
      #expect(i1 < i2)
    }

    @Test
    func secondCollectionIndexNotLessThanFirst() {
      let chained = chain([1, 2], [3, 4])
      let i1 = chained.index(chained.startIndex, offsetBy: 2)  // second collection
      let i2 = chained.startIndex  // first collection
      #expect(!(i1 < i2))
    }

    @Test
    func equalIndicesAreEqual() {
      let chained = chain([1, 2], [3, 4])
      let i1 = chained.index(chained.startIndex, offsetBy: 2)
      let i2 = chained.index(chained.startIndex, offsetBy: 2)
      #expect(i1 == i2)
    }
  }

  // MARK: - Edge Cases

  @Suite
  struct EdgeCases {
    @Test
    func chainWithSets() {
      let chained = chain(Set([1, 2]), Set([3, 4]))
      let sorted = Array(chained).sorted()
      #expect(sorted == [1, 2, 3, 4])
    }

    @Test
    func chainWithLazySequences() {
      let chained = chain([1, 2, 3].lazy, [4, 5, 6].lazy)
      #expect(Array(chained) == [1, 2, 3, 4, 5, 6])
    }

    @Test
    func chainPreservesLaziness() {
      var evaluationCount = 0
      let lazy1 = [1, 2, 3].lazy.map { value -> Int in
        evaluationCount += 1
        return value
      }
      let lazy2 = [4, 5, 6].lazy.map { value -> Int in
        evaluationCount += 1
        return value
      }
      let chained = chain(lazy1, lazy2)

      #expect(evaluationCount == 0)

      // Only evaluate first 2 elements
      _ = chained.prefix(2).reduce(0, +)
      #expect(evaluationCount == 2)
    }

    @Test
    func multipleChains() {
      let c1 = chain([1, 2], [3, 4])
      let c2 = chain([5, 6], [7, 8])
      let combined = chain(c1, c2)
      #expect(Array(combined) == [1, 2, 3, 4, 5, 6, 7, 8])
    }
  }
}

