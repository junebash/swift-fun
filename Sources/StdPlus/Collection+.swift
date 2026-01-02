extension Collection {
  /// This collection if it contains elements, otherwise `nil`.
  ///
  /// Useful for conditional operations that should only proceed when data exists,
  /// or for providing fallbacks with nil-coalescing.
  ///
  /// ```swift
  /// // Only process if there's data
  /// if let items = results.nonEmpty {
  ///   process(items)
  /// }
  ///
  /// // Provide a fallback
  /// let items = cachedItems.nonEmpty ?? fetchItems()
  /// ```
  public var nonEmpty: Self? {
    if isEmpty { nil } else { self }
  }
}
