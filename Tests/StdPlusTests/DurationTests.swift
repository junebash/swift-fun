import StdPlus
import Testing

@Suite
struct DurationTests {
  @Suite
  struct DurationTimeInterval {
    @Test
    func timeIntervalFromSeconds() {
      let duration = Duration.seconds(1)
      #expect(duration.timeInterval == 1.0)
    }

    @Test
    func timeIntervalFromMilliseconds() {
      let duration = Duration.milliseconds(500)
      #expect(duration.timeInterval == 0.5)
    }

    @Test
    func timeIntervalFromMicroseconds() {
      let duration = Duration.microseconds(1_000_000)
      #expect(duration.timeInterval == 1.0)
    }

    @Test
    func timeIntervalFromNanoseconds() {
      let duration = Duration.nanoseconds(1_000_000_000)
      #expect(duration.timeInterval.isNearEqual(to: 1.0, tolerance: 0.000001))
    }

    @Test
    func timeIntervalFromFractionalSeconds() {
      let duration = Duration.seconds(2.5)
      #expect(duration.timeInterval == 2.5)
    }

    @Test
    func timeIntervalFromZero() {
      let duration = Duration.zero
      #expect(duration.timeInterval == 0.0)
    }

    @Test
    func timeIntervalSetterCreatesCorrectDuration() {
      var duration = Duration.zero
      duration.timeInterval = 3.0
      #expect(duration == .seconds(3))
    }

    @Test
    func timeIntervalSetterWithFractionalSeconds() {
      var duration = Duration.zero
      duration.timeInterval = 1.5
      #expect(duration == .seconds(1.5))
    }

    @Test
    func timeIntervalRoundTrip() {
      let originalInterval = 42.123
      var duration = Duration.zero
      duration.timeInterval = originalInterval
      #expect(duration.timeInterval.isNearEqual(to: originalInterval, tolerance: 0.000001))
    }

    @Test
    func timeIntervalWithLargeDuration() {
      let duration = Duration.seconds(3600)  // 1 hour
      #expect(duration.timeInterval.isNearEqual(to: 3600.0, tolerance: 0.000001))
    }

    @Test
    func timeIntervalWithSmallDuration() {
      let duration = Duration.milliseconds(1)
      #expect(duration.timeInterval.isNearEqual(to: 0.001, tolerance: 0.000001))
    }
  }
}
