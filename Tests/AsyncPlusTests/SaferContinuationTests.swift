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

  @Test
  func firstResumeReturnsNil() async throws {
    var resumeResult: Result<Int, any Error>?
    let result = try await withSaferContinuation { continuation in
      resumeResult = continuation.resume(returning: 42)
    }
    #expect(result == 42)
    #expect(resumeResult == nil)
  }

  @Test
  func secondResumeReturnsFirstResult() async throws {
    var firstResumeResult: Result<Int, any Error>?
    var secondResumeResult: Result<Int, any Error>?

    let result = try await withSaferContinuation { continuation in
      firstResumeResult = continuation.resume(returning: 42)
      secondResumeResult = continuation.resume(returning: 99)
    }

    #expect(result == 42)
    #expect(firstResumeResult == nil)

    // Second resume should return the first result
    guard let secondResult = secondResumeResult else {
      Issue.record("Expected second resume to return a result")
      return
    }

    switch secondResult {
    case .success(let value):
      #expect(value == 42)
    case .failure:
      Issue.record("Expected success, got failure")
    }
  }

  @Test
  func secondResumeWithErrorReturnsFirstSuccessResult() async throws {
    var firstResumeResult: Result<Int, any Error>?
    var secondResumeResult: Result<Int, any Error>?

    let result = try await withSaferContinuation { continuation in
      firstResumeResult = continuation.resume(returning: 42)
      secondResumeResult = continuation.resume(throwing: TestError.failed)
    }

    #expect(result == 42)
    #expect(firstResumeResult == nil)

    // Second resume should return the first result (success)
    guard let secondResult = secondResumeResult else {
      Issue.record("Expected second resume to return a result")
      return
    }

    switch secondResult {
    case .success(let value):
      #expect(value == 42)
    case .failure:
      Issue.record("Expected success, got failure")
    }
  }

  @Test
  func secondResumeWithSuccessReturnsFirstErrorResult() async {
    var firstResumeResult: Result<Int, any Error>?
    var secondResumeResult: Result<Int, any Error>?

    await #expect(throws: TestError.self) {
      try await withSaferContinuation(of: Int.self) { continuation in
        firstResumeResult = continuation.resume(throwing: TestError.failed)
        secondResumeResult = continuation.resume(returning: 42)
      }
    }

    #expect(firstResumeResult == nil)

    // Second resume should return the first result (error)
    guard let secondResult = secondResumeResult else {
      Issue.record("Expected second resume to return a result")
      return
    }

    switch secondResult {
    case .success:
      Issue.record("Expected failure, got success")
    case .failure(let error):
      #expect(error is TestError)
    }
  }

  @Test
  func canDetectAlreadyResumedContinuation() async throws {
    var wasAlreadyResumed = false

    let result = try await withSaferContinuation { continuation in
      continuation.resume(returning: 42)
      if continuation.resume(returning: 99) != nil {
        wasAlreadyResumed = true
      }
    }

    #expect(result == 42)
    #expect(wasAlreadyResumed)
  }
}
