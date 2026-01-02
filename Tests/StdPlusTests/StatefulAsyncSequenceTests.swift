import StdPlus
import Testing

@Suite
struct StatefulAsyncSequenceTests {
  @Test
  func iteratesWithState() async throws {
    let sequence = StatefulAsyncSequence(initialState: 0) {
      (state: inout Int, _: isolated (any Actor)?) async throws(Never) -> Int? in
      guard state < 5 else { return nil }
      state += 1
      return state
    }

    var results: [Int] = []
    for try await value in sequence {
      results.append(value)
    }

    #expect(results == [1, 2, 3, 4, 5])
  }

  @Test
  func emptySequence() async throws {
    let sequence = StatefulAsyncSequence(initialState: ()) {
      (_: inout Void, _: isolated (any Actor)?) async throws(Never) -> Int? in
      nil
    }

    var count = 0
    for try await _ in sequence {
      count += 1
    }

    #expect(count == 0)
  }

  @Test
  func stateIsMutated() async throws {
    struct CountState {
      var count: Int = 0
      var doubled: Int { count * 2 }
    }

    let sequence = StatefulAsyncSequence(initialState: CountState()) {
      (state: inout CountState, _: isolated (any Actor)?) async throws(Never) -> Int? in
      guard state.count < 3 else { return nil }
      state.count += 1
      return state.doubled
    }

    var results: [Int] = []
    for try await value in sequence {
      results.append(value)
    }

    #expect(results == [2, 4, 6])
  }

  @Test
  func singleElement() async throws {
    var emitted = false
    let sequence = StatefulAsyncSequence(initialState: ()) {
      (_: inout Void, _: isolated (any Actor)?) async throws(Never) -> String? in
      guard !emitted else { return nil }
      emitted = true
      return "hello"
    }

    var results: [String] = []
    for try await value in sequence {
      results.append(value)
    }

    #expect(results == ["hello"])
  }

  @Test
  func canCreateMultipleIterators() async throws {
    let sequence = StatefulAsyncSequence(initialState: 0) {
      (state: inout Int, _: isolated (any Actor)?) async throws(Never) -> Int? in
      guard state < 3 else { return nil }
      state += 1
      return state
    }

    var results1: [Int] = []
    for try await value in sequence {
      results1.append(value)
    }

    var results2: [Int] = []
    for try await value in sequence {
      results2.append(value)
    }

    // Each iterator starts fresh with initialState
    #expect(results1 == [1, 2, 3])
    #expect(results2 == [1, 2, 3])
  }

  @Test
  func throwsError() async {
    enum SequenceError: Error {
      case failed
    }

    let sequence = StatefulAsyncSequence(initialState: 0) {
      (state: inout Int, _: isolated (any Actor)?) async throws(SequenceError) -> Int? in
      if state >= 2 {
        throw SequenceError.failed
      }
      state += 1
      return state
    }

    var results: [Int] = []
    do {
      for try await value in sequence {
        results.append(value)
      }
      Issue.record("Expected error")
    } catch {
      #expect(results == [1, 2])
    }
  }

  @Test
  func worksWithComplexState() async throws {
    struct WordState {
      var words: [String]
      var index: Int = 0
    }

    let sequence = StatefulAsyncSequence(
      initialState: WordState(words: ["hello", "world", "swift"])
    ) { (state: inout WordState, _: isolated (any Actor)?) async throws(Never) -> String? in
      guard state.index < state.words.count else { return nil }
      let word = state.words[state.index]
      state.index += 1
      return word.uppercased()
    }

    var results: [String] = []
    for try await value in sequence {
      results.append(value)
    }

    #expect(results == ["HELLO", "WORLD", "SWIFT"])
  }
}
