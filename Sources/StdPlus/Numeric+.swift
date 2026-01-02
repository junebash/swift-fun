extension FloatingPoint {
  /// Returns whether this value is within the specified tolerance of another value.
  ///
  /// Floating-point arithmetic can produce small rounding errors, making exact equality
  /// checks unreliable. This method provides approximate equality comparison.
  ///
  /// ```swift
  /// let result = 0.1 + 0.2
  /// result == 0.3           // false (floating-point error)
  /// result.isNearEqual(to: 0.3, tolerance: 0.0001)  // true
  /// ```
  ///
  /// - Note: Returns `false` for comparisons involving `NaN` or infinities with finite values,
  ///   as the distance between them is undefined or infinite.
  ///
  /// - Parameters:
  ///   - other: The value to compare against.
  ///   - tolerance: The maximum allowed difference. Must be non-negative.
  /// - Returns: `true` if the absolute difference is less than or equal to `tolerance`.
  public func isNearEqual(to other: Self, tolerance: Self) -> Bool {
    abs(self - other) <= tolerance
  }
}
