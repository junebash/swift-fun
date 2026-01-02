/// An async sequence that maintains mutable state across iterations.
///
/// Unlike closures that capture state by reference, `StatefulAsyncSequence` provides
/// explicit state management where each iterator receives its own copy of the initial state.
/// The state is passed by `inout` reference to the generator, allowing mutations
/// that persist across `next()` calls.
///
/// ## Creating a stateful sequence
///
/// ```swift
/// // Count from 1 to 5
/// let counter = StatefulAsyncSequence(initialState: 0) { state, _ in
///   guard state < 5 else { return nil }
///   state += 1
///   return state
/// }
///
/// for await n in counter {
///   print(n)  // 1, 2, 3, 4, 5
/// }
/// ```
///
/// ## Multiple iterators
///
/// Each iterator created from this sequence starts with a fresh copy of `initialState`,
/// so multiple iterations are independent:
///
/// ```swift
/// for await n in counter { print(n) }  // 1, 2, 3, 4, 5
/// for await n in counter { print(n) }  // 1, 2, 3, 4, 5 (starts over)
/// ```
///
/// ## Actor isolation
///
/// The generator receives the current actor isolation context, enabling safe
/// interaction with actor-isolated state when needed.
public struct StatefulAsyncSequence<State, Element, Failure: Error> {
  /// A closure that produces the next element using mutable state.
  ///
  /// - Parameters:
  ///   - state: Mutable state that persists across iterations.
  ///   - isolation: The actor isolation context, if any.
  /// - Returns: The next element, or `nil` to end the sequence.
  public typealias Generator = (
    _ state: inout State,
    _ isolation: isolated (any Actor)?
  ) async throws(Failure) -> sending Element?

  @usableFromInline
  let initialState: State

  @usableFromInline
  let generator: Generator

  /// Creates a stateful async sequence.
  ///
  /// - Parameters:
  ///   - initialState: The starting state for each iterator.
  ///   - generator: A closure that produces elements and mutates state.
  public init(initialState: State, generator: @escaping Generator) {
    self.initialState = initialState
    self.generator = generator
  }
}

extension StatefulAsyncSequence {
  /// The iterator for a `StatefulAsyncSequence`.
  public struct Iterator {
    @usableFromInline
    var state: State?
    @usableFromInline
    let generator: Generator

    @inlinable
    init(state: State, generator: @escaping Generator) {
      self.state = state
      self.generator = generator
    }
  }
}

extension StatefulAsyncSequence.Iterator: AsyncIteratorProtocol {
  /// Advances to and returns the next element, or `nil` if no more elements exist.
  @inlinable
  public mutating func next(
    isolation: isolated (any Actor)? = #isolation
  ) async throws(Failure) -> sending Element? {
    guard var state = state.take() else { return nil }
    let element = try await generator(&state, isolation)
    self.state = state
    return element
  }
}

extension StatefulAsyncSequence: AsyncSequence {
  /// Creates an iterator that starts with a fresh copy of the initial state.
  @inlinable
  public func makeAsyncIterator() -> Iterator {
    Iterator(state: initialState, generator: generator)
  }
}
