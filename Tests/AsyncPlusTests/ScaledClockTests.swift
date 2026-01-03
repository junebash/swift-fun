import AsyncPlus
import Testing

@Suite
struct ScaledClockTests {

  @Test
  func scaledClockCreatesFromContinuousClock() {
    let baseClock = ContinuousClock()
    let scaledClock = baseClock.scaled(by: 2.0)
    #expect(scaledClock.scaling == 2.0)
  }

  @Test
  func scaledClockNowAdvancesFasterWithHigherScaling() async throws {
    let baseClock = ContinuousClock()
    let scaledClock = baseClock.scaled(by: 2.0)

    let startScaled = scaledClock.now
    let startBase = baseClock.now

    try await baseClock.sleep(for: .milliseconds(50))

    let elapsedBase = startBase.duration(to: baseClock.now)
    let elapsedScaled = startScaled.duration(to: scaledClock.now)

    // Scaled clock should show roughly 2x the elapsed time
    // Using a tolerance for timing variations
    let ratio = elapsedScaled.timeInterval / elapsedBase.timeInterval
    #expect(ratio > 1.5 && ratio < 2.5)
  }

  @Test
  func scaledClockSleepCompletesInLessRealTime() async throws {
    let baseClock = ContinuousClock()
    let scaledClock = baseClock.scaled(by: 10.0)

    let start = baseClock.now

    // Sleep for 100ms in scaled time
    try await scaledClock.sleep(for: .milliseconds(100))

    let elapsed = start.duration(to: baseClock.now)

    // Should complete in roughly 10ms real time (with some tolerance)
    #expect(elapsed < .milliseconds(50))
  }

  @Test
  func scaledClockMinimumResolutionIsScaled() {
    let baseClock = ContinuousClock()
    let scaledClock = baseClock.scaled(by: 2.0)

    let baseResolution = baseClock.minimumResolution
    let scaledResolution = scaledClock.minimumResolution

    // Scaled resolution should be half the base resolution
    #expect(scaledResolution == baseResolution / 2.0)
  }

  @Test
  func scalingFactorOfOneIsIdentity() async throws {
    let baseClock = ContinuousClock()
    let scaledClock = baseClock.scaled(by: 1.0)

    let startScaled = scaledClock.now
    let startBase = baseClock.now

    try await baseClock.sleep(for: .milliseconds(50))

    let elapsedBase = startBase.duration(to: baseClock.now)
    let elapsedScaled = startScaled.duration(to: scaledClock.now)

    // Should be approximately equal
    let diff = abs(elapsedScaled.timeInterval - elapsedBase.timeInterval)
    #expect(diff < 0.01)
  }

  @Test
  func sleepWithZeroDurationReturnsImmediately() async throws {
    let scaledClock = ContinuousClock().scaled(by: 2.0)
    let start = ContinuousClock().now

    try await scaledClock.sleep(for: .zero)

    let elapsed = start.duration(to: ContinuousClock().now)
    #expect(elapsed < .milliseconds(10))
  }

  @Test
  func sleepWithNegativeDurationReturnsImmediately() async throws {
    let scaledClock = ContinuousClock().scaled(by: 2.0)
    let start = ContinuousClock().now

    // Sleep until a deadline in the past
    let pastDeadline = scaledClock.now.advanced(by: .seconds(-1))
    try await scaledClock.sleep(until: pastDeadline, tolerance: nil)

    let elapsed = start.duration(to: ContinuousClock().now)
    #expect(elapsed < .milliseconds(10))
  }
}

// Helper for Duration.timeInterval if not already available
extension Duration {
  fileprivate var timeInterval: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) + Double(attoseconds) * 1e-18
  }
}
