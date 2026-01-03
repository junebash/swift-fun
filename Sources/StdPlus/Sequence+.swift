extension Sequence {
  /// Returns the element if the sequence contains exactly one element, otherwise `nil`.
  ///
  /// Useful when you expect a single result and want to handle both empty
  /// and multiple-result cases as failures.
  ///
  /// ```swift
  /// let user = users.filter { $0.id == id }.only
  /// // nil if no users or multiple users match
  /// ```
  ///
  /// - Returns: The single element, or `nil` if the sequence is empty or has more than one element.
  @inlinable
  public var only: Element? {
    var iterator = makeIterator()
    guard
      let first = iterator.next(),
      iterator.next() == nil
    else { return nil }
    return first
  }
}
