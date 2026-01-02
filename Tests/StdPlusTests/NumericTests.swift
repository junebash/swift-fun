import Testing

@testable import StdPlus

@Suite
struct NumericTests {

  // MARK: - isNearEqual

  @Suite
  struct IsNearEqual {

    // MARK: Double

    @Test
    func exactlyEqualDoublesAreNearEqual() {
      #expect((1.0).isNearEqual(to: 1.0, tolerance: 0.0))
    }

    @Test
    func valuesWithinToleranceAreNearEqual() {
      #expect((1.0).isNearEqual(to: 1.001, tolerance: 0.01))
    }

    @Test
    func valuesOutsideToleranceAreNotNearEqual() {
      #expect(!(1.0).isNearEqual(to: 1.1, tolerance: 0.01))
    }

    @Test
    func valuesAtExactToleranceBoundaryAreNearEqual() {
      // Use values that don't suffer from floating point representation errors
      #expect((0.0).isNearEqual(to: 0.5, tolerance: 0.5))
    }

    @Test
    func negativeValuesWithinTolerance() {
      #expect((-5.0).isNearEqual(to: -5.001, tolerance: 0.01))
    }

    @Test
    func negativeValuesOutsideTolerance() {
      #expect(!(-5.0).isNearEqual(to: -5.1, tolerance: 0.01))
    }

    @Test
    func mixedSignValuesWithinTolerance() {
      #expect((0.005).isNearEqual(to: -0.005, tolerance: 0.01))
    }

    @Test
    func mixedSignValuesOutsideTolerance() {
      #expect(!(0.5).isNearEqual(to: -0.5, tolerance: 0.01))
    }

    @Test
    func zeroValuesAreNearEqual() {
      #expect((0.0).isNearEqual(to: 0.0, tolerance: 0.0))
    }

    @Test
    func zeroNearSmallValue() {
      #expect((0.0).isNearEqual(to: 0.0001, tolerance: 0.001))
    }

    @Test
    func largeValuesWithinTolerance() {
      #expect((1_000_000.0).isNearEqual(to: 1_000_000.5, tolerance: 1.0))
    }

    @Test
    func verySmallToleranceWithExactMatch() {
      #expect((3.14159).isNearEqual(to: 3.14159, tolerance: 0.000001))
    }

    @Test
    func floatingPointArithmeticErrorsHandled() {
      // 0.1 + 0.2 is not exactly 0.3 in floating point
      let result = 0.1 + 0.2
      #expect(result.isNearEqual(to: 0.3, tolerance: 0.0000001))
    }

    // MARK: Float

    @Test
    func floatValuesWithinTolerance() {
      let a: Float = 1.0
      let b: Float = 1.001
      #expect(a.isNearEqual(to: b, tolerance: 0.01))
    }

    @Test
    func floatValuesOutsideTolerance() {
      let a: Float = 1.0
      let b: Float = 1.1
      #expect(!a.isNearEqual(to: b, tolerance: 0.01))
    }

    // MARK: Edge Cases

    @Test
    func infinityNotNearEqualToItself() {
      // inf - inf = NaN, which is not <= any tolerance
      // This is mathematically correct: infinity has no measurable distance
      #expect(!Double.infinity.isNearEqual(to: .infinity, tolerance: 0.0))
      #expect(!Double.infinity.isNearEqual(to: .infinity, tolerance: .infinity))
    }

    @Test
    func negativeInfinityNotNearEqualToItself() {
      #expect(!(-Double.infinity).isNearEqual(to: -.infinity, tolerance: 0.0))
    }

    @Test
    func infinityNotNearFiniteValue() {
      #expect(!Double.infinity.isNearEqual(to: 1000000.0, tolerance: 1000000.0))
    }

    @Test
    func nanNotNearEqualToItself() {
      // NaN is not equal to anything, including itself
      #expect(!Double.nan.isNearEqual(to: .nan, tolerance: 1.0))
    }

    @Test
    func nanNotNearEqualToFiniteValue() {
      #expect(!Double.nan.isNearEqual(to: 0.0, tolerance: 1.0))
    }

    @Test
    func zeroToleranceRequiresExactEquality() {
      #expect(!(1.0).isNearEqual(to: 1.0000001, tolerance: 0.0))
    }

    @Test
    func symmetricComparison() {
      // a.isNearEqual(to: b) should equal b.isNearEqual(to: a)
      let a = 1.5
      let b = 1.6
      let tolerance = 0.15
      #expect(a.isNearEqual(to: b, tolerance: tolerance) == b.isNearEqual(to: a, tolerance: tolerance))
    }
  }
}
