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

extension BinaryFloatingPoint {
  /// Returns this value clamped to the specified range.
  ///
  /// If the value is less than the range's lower bound, returns the lower bound.
  /// If greater than the upper bound, returns the upper bound.
  /// Otherwise, returns the value unchanged.
  ///
  /// ```swift
  /// let x = 15.0.clamped(to: 0...10)  // 10.0
  /// let y = (-5.0).clamped(to: 0...10)  // 0.0
  /// let z = 5.0.clamped(to: 0...10)  // 5.0
  /// ```
  ///
  /// - Parameter range: The closed range to clamp to.
  /// - Returns: The value constrained to `range`.
  @inlinable
  public func clamped(to range: ClosedRange<Self>) -> Self {
    switch self {
    case ..<range.lowerBound: range.lowerBound
    case range.upperBound...: range.upperBound
    default: self
    }
  }
}

extension AdditiveArithmetic {
  /// Returns this value if it is not zero, otherwise `nil`.
  ///
  /// Useful for conditional operations that should skip zero values,
  /// or for providing fallbacks with nil-coalescing.
  ///
  /// ```swift
  /// let count = items.count.nonZero() ?? defaultCount
  /// ```
  ///
  /// - Returns: This value if not equal to `.zero`, otherwise `nil`.
  @inlinable
  public consuming func nonZero() -> Self? {
    if self == .zero { nil } else { self }
  }
}

extension AdditiveArithmetic where Self: Comparable {
  /// Returns this value if it is positive (greater than zero), otherwise `nil`.
  ///
  /// Useful for conditional operations that require positive values.
  ///
  /// ```swift
  /// let duration = seconds.positive().map { Duration.seconds($0) }
  /// ```
  ///
  /// - Returns: This value if greater than `.zero`, otherwise `nil`.
  @inlinable
  public consuming func positive() -> Self? {
    if self > .zero { self } else { nil }
  }
}
