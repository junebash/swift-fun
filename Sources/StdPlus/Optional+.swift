/// An error indicating that an optional unwrap operation failed.
///
/// Thrown by `Optional.orThrow()` when the optional is `nil`. Contains type information
/// for debugging purposes.
public struct UnwrapError: Error {
  /// The type that was wrapped in the optional that failed to unwrap.
  public let wrappedType: Any.Type
}

extension Optional {
  /// Returns the wrapped value or throws the provided error.
  ///
  /// A concise alternative to `guard let` when you want to throw a specific error
  /// for `nil` values. The error is evaluated lazily, only when the optional is `nil`.
  ///
  /// ```swift
  /// let user = try users[id].orThrow(UserError.notFound(id))
  /// ```
  ///
  /// - Parameter error: The error to throw if the optional is `nil`.
  /// - Returns: The wrapped value.
  /// - Throws: The provided error if the optional is `nil`.
  public func orThrow<Failure: Error>(
    _ error: @autoclosure () -> Failure
  ) throws(Failure) -> Wrapped {
    switch self {
    case .none: throw error()
    case .some(let wrapped): return wrapped
    }
  }

  /// Returns the wrapped value or throws an `UnwrapError`.
  ///
  /// A convenient form of `orThrow` when you don't need a custom error type.
  /// The thrown error includes the wrapped type for debugging.
  ///
  /// - Returns: The wrapped value.
  /// - Throws: `UnwrapError` if the optional is `nil`.
  public func orThrow() throws(UnwrapError) -> Wrapped {
    try orThrow(UnwrapError(wrappedType: Wrapped.self))
  }

  /// Returns this optional if its value satisfies the predicate, otherwise `nil`.
  ///
  /// Enables conditional unwrapping based on the wrapped value's properties,
  /// without the verbosity of `if let` with an additional condition.
  ///
  /// ```swift
  /// let validAge = age.filter { $0 >= 0 && $0 <= 150 }
  /// let shortName = name.filter { $0.count <= 20 }
  /// ```
  ///
  /// - Parameter predicate: A closure that evaluates the wrapped value.
  /// - Returns: The original optional if the predicate returns `true`, otherwise `nil`.
  /// - Throws: Rethrows any error from `predicate`.
  @inlinable
  public func filter<E: Error>(
    _ predicate: (Wrapped) throws(E) -> Bool
  ) throws(E) -> Wrapped? {
    switch self {
    case .none:
      return nil
    case .some(let wrapped):
      return try predicate(wrapped) ? wrapped : nil
    }
  }
}
