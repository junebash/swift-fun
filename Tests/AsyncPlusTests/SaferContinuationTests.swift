import AsyncPlus
import Testing

@Suite
struct SaferContinuationTests {
  enum TestError: Error {
    case failed
  }

  @Test
  func resumeReturningDeliversValue() async throws {
    let result = try await withSaferContinuation { continuation in
      continuation.resume(returning: 42)
    }
    #expect(result == 42)
  }

  @Test
  func resumeThrowingDeliversError() async {
    await #expect(throws: TestError.self) {
      try await withSaferContinuation(of: Int.self) { continuation in
        continuation.resume(throwing: TestError.failed)
      }
    }
  }

  @Test
  func leakedContinuationThrowsError() async {
    await #expect(throws: LeakedContinuationError.self) {
      try await withSaferContinuation(of: Int.self) { _ in
        // Intentionally not calling resume
      }
    }
  }

  @Test
  func leakedContinuationErrorContainsFunction() async throws {
    let error = try await #require(throws: LeakedContinuationError.self) {
      try await withSaferContinuation(of: Int.self) { _ in
        // Intentionally not calling resume
      }
    }
    #expect(error.function.contains("leakedContinuationErrorContainsFunction"))
  }

  @Test
  func multipleResumeCallsAreIgnored() async throws {
    // This shouldn't crash - subsequent calls are ignored
    let result = try await withSaferContinuation { continuation in
      continuation.resume(returning: 42)
      // These should be silently ignored
    }
    #expect(result == 42)
  }

  @Test
  func worksWithVoidReturn() async throws {
    try await withSaferContinuation(of: Void.self) { continuation in
      continuation.resume(returning: ())
    }
  }

  @Test
  func worksWithStringValue() async throws {
    let result = try await withSaferContinuation { continuation in
      continuation.resume(returning: "hello")
    }
    #expect(result == "hello")
  }
}
