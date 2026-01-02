public enum Either<Left: ~Copyable, Right: ~Copyable>: ~Copyable {
  case left(Left)
  case right(Right)
}

extension Either {
  @inlinable
  public init(left: Left) {
    self = .left(left)
  }

  @inlinable
  public init(right: Right) {
    self = .right(right)
  }

  @inlinable
  public func map<NewRight, E: Error>(
    _ transform: (Right) throws(E) -> NewRight
  ) throws(E) -> Either<Left, NewRight> {
    switch self {
    case .left(let left): .left(left)
    case .right(let right): .right(try transform(right))
    }
  }

  @inlinable
  public func flatMap<NewRight, E: Error>(
    _ transform: (Right) throws(E) -> Either<Left, NewRight>
  ) throws(E) -> Either<Left, NewRight> {
    switch self {
    case .left(let left): .left(left)
    case .right(let right): try transform(right)
    }
  }

  @inlinable
  public var left: Left? {
    switch self {
    case .left(let left): left
    case .right: nil
    }
  }

  @inlinable
  public var right: Right? {
    switch self {
    case .left: nil
    case .right(let right): right
    }
  }
}

extension Either: Copyable where Left: Copyable, Right: Copyable {}
extension Either: Sendable where Left: Sendable & ~Copyable, Right: Sendable & ~Copyable {}
extension Either: Equatable where Left: Equatable, Right: Equatable {}
extension Either: Hashable where Left: Hashable, Right: Hashable {}

extension Either: Sequence where Left: Sequence, Right: Sequence, Left.Element == Right.Element {
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
