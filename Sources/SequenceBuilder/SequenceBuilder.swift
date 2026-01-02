import Either

/// A result builder for constructing sequences declaratively.
///
/// `SequenceBuilder` enables SwiftUI-like syntax for building sequences, supporting
/// single elements, existing sequences, conditionals, loops, and optional values.
///
/// ## Basic usage
///
/// ```swift
/// let numbers = Array {
///   1
///   2
///   [3, 4, 5]
///   if includeMore {
///     6
///   }
///   for n in 7...9 {
///     n
///   }
/// }
/// ```
///
/// ## Type inference
///
/// The element type is inferred from the expressions. All expressions must produce
/// the same element type.
@resultBuilder
public enum SequenceBuilder<Element> {
  /// Wraps a single element as a one-element sequence.
  @inlinable
  public static func buildExpression(_ expression: Element) -> CollectionOfOne<Element> {
    CollectionOfOne(expression)
  }

  /// Passes through an existing sequence unchanged.
  @inlinable
  public static func buildExpression<S: Sequence<Element>>(_ expression: S) -> S {
    expression
  }

  /// Produces an empty sequence for empty blocks.
  @inlinable
  public static func buildBlock() -> EmptyCollection<Element> {
    EmptyCollection()
  }

  /// Passes through the first sequence in a block.
  @inlinable
  public static func buildPartialBlock<First: Sequence<Element>>(first: First) -> First {
    first
  }

  /// Chains accumulated sequences with the next sequence.
  @inlinable
  public static func buildPartialBlock<Accumulated: Sequence<Element>, Next: Sequence<Element>>(
    accumulated: Accumulated,
    next: Next
  ) -> Chain2Sequence<Accumulated, Next> {
    chain(accumulated, next)
  }

  /// Handles optional sequences, producing an empty sequence for `nil`.
  @inlinable
  public static func buildOptional<S: Sequence<Element>>(
    _ component: S?
  ) -> Either<EmptyCollection<Element>, S> {
    component.map { .right($0) } ?? .left(EmptyCollection())
  }

  /// Handles the first branch of an `if-else`.
  @inlinable
  public static func buildEither<First: Sequence<Element>, Second: Sequence<Element>>(
    first component: First
  ) -> Either<First, Second> {
    .left(component)
  }

  /// Handles the second branch of an `if-else`.
  @inlinable
  public static func buildEither<First: Sequence<Element>, Second: Sequence<Element>>(
    second component: Second
  ) -> Either<First, Second> {
    .right(component)
  }

  /// Flattens an array of sequences from `for` loops.
  @inlinable
  public static func buildArray<S: Sequence<Element>>(_ components: [S]) -> FlattenSequence<[S]> {
    components.joined()
  }

  /// Passes through sequences from availability-checked blocks.
  @inlinable
  public static func buildLimitedAvailability<S: Sequence<Element>>(_ component: S) -> S {
    component
  }
}

/// Builds a sequence using `SequenceBuilder` syntax.
///
/// A standalone function for constructing sequences when you don't want to
/// initialize a specific collection type.
///
/// ```swift
/// let seq = buildSequence {
///   1
///   2
///   3
/// }
/// for n in seq { print(n) }
/// ```
///
/// - Parameters:
///   - of: The element type (usually inferred).
///   - content: A builder closure producing the sequence.
/// - Returns: A sequence containing all elements from the builder.
/// - Throws: Rethrows any error from `content`.
public func buildSequence<Element, Failure: Error>(
  of: Element.Type = Element.self,
  @SequenceBuilder<Element> _ content: () throws(Failure) -> some Sequence<Element>
) throws(Failure) -> some Sequence<Element> {
  try content()
}

extension RangeReplaceableCollection {
  /// Creates a collection using `SequenceBuilder` syntax.
  ///
  /// ```swift
  /// let array = Array {
  ///   1
  ///   2
  ///   [3, 4, 5]
  /// }
  /// ```
  ///
  /// - Parameter build: A builder closure producing elements.
  public init(@SequenceBuilder<Element> build: () -> some Sequence<Element>) {
    self.init(build())
  }
}

extension SetAlgebra {
  /// Creates a set using `SequenceBuilder` syntax.
  ///
  /// Duplicate elements are automatically deduplicated as per set semantics.
  ///
  /// ```swift
  /// let set = Set {
  ///   1
  ///   2
  ///   [3, 4, 5]
  /// }
  /// ```
  ///
  /// - Parameter build: A builder closure producing elements.
  public init(@SequenceBuilder<Element> build: () -> some Sequence<Element>) {
    self.init(build())
  }
}
