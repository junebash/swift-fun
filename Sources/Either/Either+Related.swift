extension Result {
  /// Creates a `Result` from an `Either` where the left type is the failure type.
  ///
  /// Converts the functional `Either` representation to Swift's standard `Result` type.
  /// Left values become failures; right values become successes.
  ///
  /// - Parameter either: An `Either` where `.left` represents failure and `.right` represents success.
  @inlinable
  public init(_ either: Either<Failure, Success>) {
    switch either {
    case .left(let failure): self = .failure(failure)
    case .right(let success): self = .success(success)
    }
  }
}

extension Either where Left: Error {
  /// Creates an `Either` from a `Result`.
  ///
  /// Converts Swift's standard `Result` type to an `Either` representation.
  /// Failures become left values; successes become right values.
  ///
  /// - Parameter result: A `Result` to convert.
  @inlinable
  public init(_ result: Result<Right, Left>) {
    switch result {
    case .failure(let error): self = .left(error)
    case .success(let value): self = .right(value)
    }
  }
}

extension Optional where Wrapped: Sequence {
  /// Returns a sequence that is either this optional's wrapped sequence or empty.
  ///
  /// Provides a way to use an optional sequence in contexts requiring a concrete `Sequence`,
  /// without needing to unwrap or provide a default. The returned `Either` conforms to
  /// `Sequence` and will iterate over the wrapped elements if present, or produce no elements
  /// if `nil`.
  ///
  /// - Returns: An `Either` containing either an empty collection (if `nil`) or the wrapped sequence.
  public func orEmpty() -> Either<EmptyCollection<Wrapped.Element>, Wrapped> {
    map { .right($0) } ?? .left(EmptyCollection())
  }
}

extension Sequence {
  /// Partitions a sequence of `Either` values into separate arrays of lefts and rights.
  ///
  /// Useful for processing a collection of results where you want to handle all successes
  /// and all failures separately.
  ///
  /// ```swift
  /// let results: [Either<Error, User>] = fetchUsers(ids)
  /// let (errors, users) = results.separated()
  /// // Handle errors and users independently
  /// ```
  ///
  /// - Returns: A tuple containing an array of all left values and an array of all right values,
  ///   preserving their original order within each array.
  public func separated<Left, Right>() -> (lefts: [Left], rights: [Right])
  where Element == Either<Left, Right> {
    reduce(into: (lefts: [Left](), rights: [Right]())) { result, element in
      switch element {
      case .left(let left): result.lefts.append(left)
      case .right(let right): result.rights.append(right)
      }
    }
  }
}
