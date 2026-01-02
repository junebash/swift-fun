/// A value that holds one of two possible types.
///
/// `Either` represents a choice between two alternatives. By convention, `Left` often represents
/// an error or secondary case, while `Right` represents success or the primary case. This follows
/// the functional programming tradition where "right" is "correct."
///
/// Unlike `Result`, `Either` places no constraints on its type parameters, making it suitable
/// for any scenario requiring a discriminated union of two types.
///
/// ## Working with non-copyable types
///
/// `Either` supports non-copyable types through the `~Copyable` constraint. When either type
/// parameter is non-copyable, the `Either` itself becomes non-copyable.
///
/// ## Example
///
/// ```swift
/// func parse(_ input: String) -> Either<ParseError, Document> {
///   guard let doc = Document(input) else {
///     return .left(ParseError.invalidFormat)
///   }
///   return .right(doc)
/// }
///
/// let result = parse(userInput)
///   .map { $0.title }
///   .fold(left: { "Error: \($0)" }, right: { $0 })
/// ```
public enum Either<Left: ~Copyable, Right: ~Copyable>: ~Copyable {
  case left(Left)
  case right(Right)
}

extension Either {
  /// Creates an `Either` containing a left value.
  @inlinable
  public init(left: Left) {
    self = .left(left)
  }

  /// Creates an `Either` containing a right value.
  @inlinable
  public init(right: Right) {
    self = .right(right)
  }

  /// Transforms the right value, leaving left values unchanged.
  ///
  /// Use `map` to apply a transformation to successful values while preserving errors.
  /// If this instance contains a left value, it passes through untouched.
  ///
  /// - Parameter transform: A closure that transforms the right value.
  /// - Returns: An `Either` with the transformed right value, or the original left value.
  /// - Throws: Rethrows any error from `transform`.
  @inlinable
  public func map<NewRight, E: Error>(
    _ transform: (Right) throws(E) -> NewRight
  ) throws(E) -> Either<Left, NewRight> {
    switch self {
    case .left(let left): .left(left)
    case .right(let right): .right(try transform(right))
    }
  }

  /// Transforms the right value with a function that returns another `Either`.
  ///
  /// Use `flatMap` to chain operations that may themselves produce left values.
  /// This prevents nested `Either` types that would result from using `map` alone.
  ///
  /// - Parameter transform: A closure that transforms the right value into a new `Either`.
  /// - Returns: The result of `transform` if this is a right value, otherwise the original left.
  /// - Throws: Rethrows any error from `transform`.
  @inlinable
  public func flatMap<NewRight, E: Error>(
    _ transform: (Right) throws(E) -> Either<Left, NewRight>
  ) throws(E) -> Either<Left, NewRight> {
    switch self {
    case .left(let left): .left(left)
    case .right(let right): try transform(right)
    }
  }

  /// The left value if this instance is `.left`, otherwise `nil`.
  @inlinable
  public var left: Left? {
    switch self {
    case .left(let left): left
    case .right: nil
    }
  }

  /// The right value if this instance is `.right`, otherwise `nil`.
  @inlinable
  public var right: Right? {
    switch self {
    case .left: nil
    case .right(let right): right
    }
  }

  /// Transforms the left value, leaving right values unchanged.
  ///
  /// The dual of `map`. Use `mapLeft` to transform error types or convert
  /// between different left representations.
  ///
  /// - Parameter transform: A closure that transforms the left value.
  /// - Returns: An `Either` with the transformed left value, or the original right value.
  /// - Throws: Rethrows any error from `transform`.
  @inlinable
  public func mapLeft<NewLeft, E: Error>(
    _ transform: (Left) throws(E) -> NewLeft
  ) throws(E) -> Either<NewLeft, Right> {
    switch self {
    case .left(let left): .left(try transform(left))
    case .right(let right): .right(right)
    }
  }

  /// Transforms both the left and right values simultaneously.
  ///
  /// Use `bimap` when you need to convert an `Either` to a completely different type,
  /// transforming both cases in one operation.
  ///
  /// - Parameters:
  ///   - transformLeft: A closure that transforms the left value.
  ///   - transformRight: A closure that transforms the right value.
  /// - Returns: An `Either` with both sides transformed.
  /// - Throws: Rethrows any error from either transform.
  @inlinable
  public func bimap<NewLeft, NewRight, E: Error>(
    left transformLeft: (Left) throws(E) -> NewLeft,
    right transformRight: (Right) throws(E) -> NewRight
  ) throws(E) -> Either<NewLeft, NewRight> {
    switch self {
    case .left(let left): .left(try transformLeft(left))
    case .right(let right): .right(try transformRight(right))
    }
  }

  /// Reduces this `Either` to a single value by applying one of two functions.
  ///
  /// The fundamental way to extract a value from an `Either`. Both transforms must produce
  /// the same result type, collapsing the two possibilities into one.
  ///
  /// - Parameters:
  ///   - transformLeft: A closure to apply if this is a left value.
  ///   - transformRight: A closure to apply if this is a right value.
  /// - Returns: The result of applying the appropriate transform.
  /// - Throws: Rethrows any error from the applied transform.
  @inlinable
  public func fold<Result, E: Error>(
    left transformLeft: (Left) throws(E) -> Result,
    right transformRight: (Right) throws(E) -> Result
  ) throws(E) -> Result {
    switch self {
    case .left(let left): try transformLeft(left)
    case .right(let right): try transformRight(right)
    }
  }
}

extension Either where Left: Copyable, Right: Copyable {
  /// An `Either` with the left and right types exchanged.
  ///
  /// Useful when interfacing with APIs that expect the opposite orientation,
  /// or when the "success" and "failure" semantics need to be inverted.
  @inlinable
  public var swapped: Either<Right, Left> {
    switch self {
    case .left(let left): .right(left)
    case .right(let right): .left(right)
    }
  }
}

extension Either: Copyable where Left: Copyable, Right: Copyable {}
extension Either: Sendable where Left: Sendable & ~Copyable, Right: Sendable & ~Copyable {}
extension Either: Equatable where Left: Equatable, Right: Equatable {}
extension Either: Hashable where Left: Hashable, Right: Hashable {}

extension Either: Sequence where Left: Sequence, Right: Sequence, Left.Element == Right.Element {
  /// An iterator over the elements of an `Either` containing sequences.
  public struct Iterator: IteratorProtocol {
    @usableFromInline var left: Left.Iterator?
    @usableFromInline var right: Right.Iterator?

    @inlinable
    init(left: Left.Iterator? = nil, right: Right.Iterator? = nil) {
      self.left = left
      self.right = right
    }

    @inlinable
    public mutating func next() -> Left.Element? {
      left?.next() ?? right?.next()
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    switch self {
    case .left(let left): Iterator(left: left.makeIterator())
    case .right(let right): Iterator(right: right.makeIterator())
    }
  }
}
