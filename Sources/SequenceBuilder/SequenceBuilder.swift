import Either

@resultBuilder
public enum SequenceBuilder<Element> {
  @inlinable
  public static func buildExpression(_ expression: Element) -> CollectionOfOne<Element> {
    CollectionOfOne(expression)
  }

  @inlinable
  public static func buildExpression<S: Sequence<Element>>(_ expression: S) -> S {
    expression
  }

  @inlinable
  public static func buildBlock() -> EmptyCollection<Element> {
    EmptyCollection()
  }

  @inlinable
  public static func buildPartialBlock<First: Sequence<Element>>(first: First) -> First {
    first
  }

  @inlinable
  public static func buildPartialBlock<Accumulated: Sequence<Element>, Next: Sequence<Element>>(
    accumulated: Accumulated,
    next: Next
  ) -> Chain2Sequence<Accumulated, Next> {
    chain(accumulated, next)
  }

  @inlinable
  public static func buildOptional<S: Sequence<Element>>(
    _ component: S?
  ) -> Either<EmptyCollection<Element>, S> {
    component.map { .right($0) } ?? .left(EmptyCollection())
  }

  @inlinable
  public static func buildEither<First: Sequence<Element>, Second: Sequence<Element>>(
    first component: First
  ) -> Either<First, Second> {
    .left(component)
  }

  @inlinable
  public static func buildEither<First: Sequence<Element>, Second: Sequence<Element>>(
    second component: Second
  ) -> Either<First, Second> {
    .right(component)
  }

  @inlinable
  public static func buildArray<S: Sequence<Element>>(_ components: [S]) -> FlattenSequence<[S]> {
    components.joined()
  }

  @inlinable
  public static func buildLimitedAvailability<S: Sequence<Element>>(_ component: S) -> S {
    component
  }
}

public func buildSequence<Element, Failure: Error>(
  of: Element.Type = Element.self,
  @SequenceBuilder<Element> _ content: () throws(Failure) -> some Sequence<Element>
) throws(Failure) -> some Sequence<Element> {
  try content()
}

extension RangeReplaceableCollection {
  public init(@SequenceBuilder<Element> build: () -> some Sequence<Element>) {
    self.init(build())
  }
}

extension SetAlgebra {
  public init(@SequenceBuilder<Element> build: () -> some Sequence<Element>) {
    self.init(build())
  }
}
