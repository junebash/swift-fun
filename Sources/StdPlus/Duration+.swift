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
    // Split into (seconds, attoseconds) so Int64 seconds round-trip exactly through Double; going through Int128(attoseconds) truncates above ~2^53.
    get {
      let (sec, atto) = components
      return Double(sec) + Double(atto) * 1e-18
    }
    set { self = .seconds(newValue) }
  }
}
