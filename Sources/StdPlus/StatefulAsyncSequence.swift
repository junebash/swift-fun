
public struct StatefulAsyncSequence<State, Element, Failure: Error> {
  public typealias Generator = (
    _ state: inout State,
    _ isolation: isolated (any Actor)?
  ) async throws(Failure) -> sending Element?

  @usableFromInline
  let initialState: State

  @usableFromInline
  let generator: Generator

  public init(initialState: State, generator: @escaping Generator) {
    self.initialState = initialState
    self.generator = generator
  }
}

extension StatefulAsyncSequence {
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
  @inlinable
  public func makeAsyncIterator() -> Iterator {
    Iterator(state: initialState, generator: generator)
  }
}
