public struct UnwrapError: Error {
  let wrappedType: Any.Type
}

extension Optional {
  public func orThrow<Failure: Error>(
    _ error: @autoclosure () -> Failure
  ) throws(Failure) -> Wrapped {
    switch self {
    case .none: throw error()
    case .some(let wrapped): return wrapped
    }
  }

  public func orThrow() throws(UnwrapError) -> Wrapped {
    try orThrow(UnwrapError(wrappedType: Wrapped.self))
  }
}
