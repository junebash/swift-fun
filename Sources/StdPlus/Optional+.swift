/// An error indicating that an optional unwrap operation failed.
///
/// Thrown by `Optional.orThrow()` and `Optional.takeOrThrow()` when the optional is `nil`.
/// Contains type information for debugging purposes.
public struct UnwrapError<Wrapped>: Error {
  /// The type that was wrapped in the optional that failed to unwrap.
  public let type: Wrapped.Type

  /// Creates an unwrap error for the specified type.
  public init(type: Wrapped.Type = Wrapped.self) {
    self.type = type
  }
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
  /// - Throws: `UnwrapError<Wrapped>` if the optional is `nil`.
  public func orThrow() throws(UnwrapError<Wrapped>) -> Wrapped {
    try orThrow(UnwrapError<Wrapped>())
  }

  /// Removes and returns the wrapped value, or throws the provided error.
  ///
  /// Similar to `orThrow`, but mutates the optional by setting it to `nil` after
  /// extracting the value. Useful when you need to consume the value.
  ///
  /// ```swift
  /// var pending = pendingTask
  /// let task = try pending.takeOrThrow(TaskError.noPendingTask)
  /// ```
  ///
  /// - Parameter error: The error to throw if the optional is `nil`.
  /// - Returns: The wrapped value.
  /// - Throws: The provided error if the optional is `nil`.
  public mutating func takeOrThrow<Failure: Error>(
    _ error: @autoclosure () -> Failure
  ) throws(Failure) -> Wrapped {
    guard let value = self.take() else { throw error() }
    return value
  }

  /// Removes and returns the wrapped value, or throws an `UnwrapError`.
  ///
  /// A convenient form of `takeOrThrow` when you don't need a custom error type.
  ///
  /// - Returns: The wrapped value.
  /// - Throws: `UnwrapError<Wrapped>` if the optional is `nil`.
  public mutating func takeOrThrow() throws(UnwrapError<Wrapped>) -> Wrapped {
    try takeOrThrow(UnwrapError<Wrapped>())
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

  /// Transforms the wrapped value using an async closure.
  ///
  /// An async variant of `map` that allows the transform to be asynchronous.
  ///
  /// ```swift
  /// let user = try await userId.map { await fetchUser($0) }
  /// ```
  ///
  /// - Parameter transform: An async closure that transforms the wrapped value.
  /// - Returns: The transformed value, or `nil` if this optional was `nil`.
  /// - Throws: Rethrows any error from `transform`.
  @inlinable
  public func map<Output, E: Error>(
    _ transform: (Wrapped) async throws(E) -> Output
  ) async throws(E) -> Output? {
    switch self {
    case .none: nil
    case .some(let wrapped): try await transform(wrapped)
    }
  }

  /// Transforms the wrapped value using an async closure that returns an optional.
  ///
  /// An async variant of `flatMap` that allows the transform to be asynchronous.
  ///
  /// ```swift
  /// let profile = try await userId.flatMap { await fetchProfile($0) }
  /// ```
  ///
  /// - Parameter transform: An async closure that transforms the wrapped value to an optional.
  /// - Returns: The transformed optional value, or `nil` if this optional was `nil`.
  /// - Throws: Rethrows any error from `transform`.
  @inlinable
  public func flatMap<Output, E: Error>(
    _ transform: (Wrapped) async throws(E) -> Output?
  ) async throws(E) -> Output? {
    switch self {
    case .none: nil
    case .some(let wrapped): try await transform(wrapped)
    }
  }
}
