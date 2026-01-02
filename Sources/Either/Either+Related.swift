extension Result {
  @inlinable
  public init(_ either: Either<Failure, Success>) {
    switch either {
    case .left(let failure): self = .failure(failure)
    case .right(let success): self = .success(success)
    }
  }
}

extension Optional where Wrapped: Sequence {
  public func orEmpty() -> Either<EmptyCollection<Wrapped.Element>, Wrapped> {
    map { .right($0) } ?? .left(EmptyCollection())
  }
}

extension Sequence {
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
