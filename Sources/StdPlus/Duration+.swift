extension Duration {
  /// The duration expressed as a `Double` representing seconds.
  ///
  /// Provides interoperability with APIs that use `TimeInterval` (a `Double` alias)
  /// for time values, such as Foundation's date and animation APIs.
  ///
  /// The getter converts from the internal attosecond representation to seconds.
  /// The setter creates a new duration from the provided seconds value.
  ///
  /// - Note: Very large or precise durations may lose precision when converted to `Double`.
  public var timeInterval: Double {
    get { Double(attoseconds) * 0.000_000_000__000_000_001 }
    set { self = .seconds(newValue) }
  }
}
