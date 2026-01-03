import Synchronization

/// An error indicating that a continuation was never resumed before being deallocated.
///
/// Thrown when a `SaferContinuation` is deallocated without being explicitly resumed.
/// This prevents the common "continuation leaked" runtime warning by providing a
/// proper error to the awaiting code.
public struct LeakedContinuationError: Error, Sendable {
  /// The function where the continuation was created.
  public let function: String

  /// Creates a leaked continuation error.
  ///
  /// - Parameter function: The function where the continuation was created.
  public init(function: String) {
    self.function = function
  }
}

/// A continuation wrapper that safely handles the "leaked continuation" problem.
///
/// Unlike `CheckedContinuation`, which triggers a runtime warning when leaked,
/// `SaferContinuation` resumes with a `LeakedContinuationError` in its deinitializer.
/// This ensures the awaiting code always receives either a value or an error.
///
/// ```swift
/// let value = try await withSaferContinuation { continuation in
///   // If this closure exits without calling resume,
///   // the awaiter receives a LeakedContinuationError
///   someCallback { result in
///     continuation.resume(returning: result)
///   }
/// }
/// ```
public final class SaferContinuation<Success: Sendable>: Sendable {
  @usableFromInline
  let _continuation: Mutex<CheckedContinuation<Success, any Error>?>

  @usableFromInline
  let function: String

  @usableFromInline
  init(continuation: CheckedContinuation<Success, any Error>, function: String) {
    self._continuation = Mutex(continuation)
    self.function = function
  }

  deinit {
    _continuation.withLock { $0?.resume(throwing: LeakedContinuationError(function: function)) }
  }

  /// Resumes the continuation with a successful value.
  ///
  /// This method can only be called once. Subsequent calls are ignored.
  ///
  /// - Parameter value: The value to return to the awaiting code.
  @inlinable
  public consuming func resume(returning value: consuming sending Success) {
    _continuation.withLock { $0.take() }?.resume(returning: value)
  }

  /// Resumes the continuation with an error.
  ///
  /// This method can only be called once. Subsequent calls are ignored.
  ///
  /// - Parameter error: The error to throw to the awaiting code.
  @inlinable
  public consuming func resume(throwing error: any Error) {
    _continuation.withLock { $0.take() }?.resume(throwing: error)
  }
}

/// Suspends the current task and invokes a closure with a `SaferContinuation`.
///
/// Use this function to bridge callback-based APIs to async/await. Unlike
/// `withCheckedThrowingContinuation`, if the continuation is never resumed,
/// this function throws a `LeakedContinuationError` instead of hanging forever.
///
/// ```swift
/// func fetchData() async throws -> Data {
///   try await withSaferContinuation { continuation in
///     legacyFetch { result in
///       switch result {
///       case .success(let data):
///         continuation.resume(returning: data)
///       case .failure(let error):
///         continuation.resume(throwing: error)
///       }
///     }
///   }
/// }
/// ```
///
/// - Parameters:
///   - type: The type of value to return (usually inferred).
///   - isolation: The actor isolation context.
///   - function: The calling function (for error reporting).
///   - work: A closure that receives the continuation. Must call `resume` exactly once.
/// - Returns: The value passed to `resume(returning:)`.
/// - Throws: The error passed to `resume(throwing:)`, or `LeakedContinuationError` if leaked.
@inlinable
public func withSaferContinuation<Success: Sendable>(
  of: Success.Type = Success.self,
  isolation: isolated (any Actor)? = #isolation,
  function: String = #function,
  _ work: (consuming SaferContinuation<Success>) -> Void
) async throws -> sending Success {
  try await withCheckedThrowingContinuation(
    isolation: isolation,
    function: function
  ) {
    work(SaferContinuation(continuation: $0, function: function))
  }
}
