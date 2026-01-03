extension Clock where Self.Duration == Swift.Duration {
  /// Creates a scaled version of this clock.
  ///
  /// A scaled clock runs faster or slower than the original clock by the given factor.
  /// A scaling factor of 2.0 makes time pass twice as fast; 0.5 makes it half as fast.
  ///
  /// This is useful for testing time-dependent code or creating fast-forward effects.
  ///
  /// ```swift
  /// // Create a clock that runs 10x faster
  /// let fastClock = ContinuousClock().scaled(by: 10.0)
  /// try await fastClock.sleep(for: .seconds(10))  // Actually sleeps ~1 second
  /// ```
  ///
  /// - Parameter scalingFactor: The time scaling factor. Must be positive.
  /// - Returns: A new clock that scales time by the given factor.
  public func scaled(by scalingFactor: Double) -> ScaledClock<Self> {
    ScaledClock(rootClock: self, scaling: scalingFactor, start: now)
  }
}

/// A clock that scales time relative to an underlying root clock.
///
/// `ScaledClock` makes time appear to pass faster or slower by the configured
/// scaling factor. This is particularly useful for testing or debugging
/// time-dependent code without waiting for real time to pass.
///
/// Create a scaled clock using the `scaled(by:)` method on any clock:
///
/// ```swift
/// let clock = ContinuousClock().scaled(by: 2.0)  // Time passes 2x faster
/// ```
public final class ScaledClock<RootClock: Clock<Duration>>: Sendable {
  /// The underlying clock that provides actual timing.
  public let rootClock: RootClock

  /// The time scaling factor.
  ///
  /// Values greater than 1.0 make time pass faster; values less than 1.0 slow it down.
  public let scaling: Double

  /// The instant when this scaled clock was created.
  public let start: RootClock.Instant

  @usableFromInline
  init(rootClock: RootClock, scaling: Double, start: RootClock.Instant) {
    self.rootClock = rootClock
    self.scaling = scaling
    self.start = start
  }
}

extension ScaledClock: Clock {
  public typealias Instant = RootClock.Instant

  /// Suspends until the given deadline in scaled time.
  ///
  /// The actual sleep duration is divided by the scaling factor.
  /// For example, with a 2.0 scaling factor, sleeping until a deadline
  /// 10 seconds away will actually sleep for 5 seconds.
  ///
  /// - Parameters:
  ///   - deadline: The instant to sleep until, in scaled time.
  ///   - tolerance: The allowed tolerance for waking up.
  /// - Throws: `CancellationError` if the task is cancelled.
  public func sleep(
    until deadline: RootClock.Instant,
    tolerance: RootClock.Instant.Duration?
  ) async throws {
    let duration = now.duration(to: deadline)
    guard duration > .zero else { return }
    try await rootClock.sleep(
      for: duration / scaling,
      tolerance: tolerance.map { $0 / scaling }
    )
  }

  /// The current instant in scaled time.
  ///
  /// Returns a time that has advanced from the start instant by the
  /// root clock's elapsed time multiplied by the scaling factor.
  public var now: RootClock.Instant {
    start.advanced(by: start.duration(to: rootClock.now) * scaling)
  }

  /// The minimum resolution of the scaled clock.
  ///
  /// Returns the root clock's resolution divided by the scaling factor.
  public var minimumResolution: Duration {
    rootClock.minimumResolution / scaling
  }
}
