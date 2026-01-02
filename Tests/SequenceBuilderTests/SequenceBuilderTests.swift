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
