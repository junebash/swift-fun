import Testing

@testable import SequenceBuilder

@Suite
struct SequenceBuilderTests {
  let statement = false

  @SequenceBuilder<Int>
  var sequence: some Sequence<Int> {
    [1]
    2
    [3.0, 4.1, 5.2].lazy.map { Int($0.rounded(.down)) }

    if !statement {
      CollectionOfOne(6).lazy
        .enumerated()
        .lazy
        .flatMap { [$0, $1] }
        .dropFirst()
    }

    if statement {
      [98274938] as Set
    } else {
      ["hello"[...]: 7].values
    }
    if statement {
      93847928347290
    }
    for value in [8, 9] {
      value
    }
  }

  @Test
  func arrayFromSequence() async throws {
    #expect(Array(sequence) == [1, 2, 3, 4, 5, 6, 7, 8, 9])
  }

  @Test
  func setFromSequence() {
    #expect(Set(sequence) == [1, 2, 3, 4, 5, 6, 7, 8, 9])
  }

  @Test
  func arrayBuilderInit() {
    #expect(Array(sequence) == Array { 1; 2; 3; 4; 5; 6; 7; 8; [9] })
  }

  @Test
  func setBuilderInit() {
    #expect(Set(sequence) == Set { [1]; 2; 3; 4; 5; 6; 7; 8; [9] })
  }

  @Test
  func arrayEmptyBuilderInit() {
    #expect([Int](build: {}) == [])
  }

  @Test
  func setEmptyBuilderInit() {
    #expect(Set<Int>(build: {}) == [])
  }
}

// MARK: - buildSequence Function Tests

@Suite
struct BuildSequenceFunctionTests {
  @Test
  func basicBuildSequence() {
    let seq = buildSequence(of: Int.self) {
      1
      2
      3
    }
    #expect(Array(seq) == [1, 2, 3])
  }

  @Test
  func buildSequenceWithTypeInference() {
    let seq = buildSequence {
      "hello"
      "world"
    }
    #expect(Array(seq) == ["hello", "world"])
  }

  @Test
  func buildSequenceEmpty() {
    let seq = buildSequence(of: Int.self) {}
    #expect(Array(seq).isEmpty)
  }

  @Test
  func buildSequenceWithConditional() {
    let condition = true
    let seq = buildSequence {
      1
      if condition {
        2
      }
      3
    }
    #expect(Array(seq) == [1, 2, 3])
  }

  @Test
  func buildSequenceWithConditionalFalse() {
    let condition = false
    let seq = buildSequence {
      1
      if condition {
        2
      }
      3
    }
    #expect(Array(seq) == [1, 3])
  }

  @Test
  func buildSequenceWithIfElse() {
    let useFirst = true
    let seq = buildSequence {
      if useFirst {
        1
        2
      } else {
        3
        4
      }
    }
    #expect(Array(seq) == [1, 2])
  }

  @Test
  func buildSequenceWithForLoop() {
    let seq = buildSequence {
      for i in 1...3 {
        i * 10
      }
    }
    #expect(Array(seq) == [10, 20, 30])
  }
}
