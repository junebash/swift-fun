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
  enum State {
    case pending(CheckedContinuation<Success, any Error>)
    case resumed(Result<Success, any Error>)

    @inlinable
    mutating func resume(
      with result: consuming Result<Success, any Error>
    ) -> Result<Success, any Error>? {
      switch self {
      case .pending(let continuation):
        continuation.resume(with: result)
        self = .resumed(result)
        return nil
      case .resumed(let result):
        return result
      }
    }
  }

  @usableFromInline
  let state: Mutex<State>

  @usableFromInline
  let function: String

  @usableFromInline
  init(continuation: CheckedContinuation<Success, any Error>, function: String) {
    self.state = Mutex(.pending(continuation))
    self.function = function
  }

  deinit {
    state.withLock {
      if case .pending(let continuation) = $0 {
        continuation.resume(throwing: LeakedContinuationError(function: function))
      }
    }
  }

  /// Resumes the continuation with a successful value.
  ///
  /// This method can only be called once. Subsequent calls are ignored but return
  /// the result from the first resume call.
  ///
  /// - Parameter value: The value to return to the awaiting code.
  /// - Returns: `nil` if this is the first resume call, or the result from the
  ///   previous resume call if the continuation was already resumed.
  ///
  /// ## Example
  /// ```swift
  /// if let previousResult = continuation.resume(returning: value) {
  ///   // Continuation was already resumed with previousResult
  ///   print("Warning: attempted to resume continuation twice")
  /// }
  /// ```
  @inlinable
  @discardableResult
  public consuming func resume(
    returning value: consuming sending Success
  ) -> sending Result<Success, any Error>? {
    resume(with: .success(value))
  }

  /// Resumes the continuation with an error.
  ///
  /// This method can only be called once. Subsequent calls are ignored but return
  /// the result from the first resume call.
  ///
  /// - Parameter error: The error to throw to the awaiting code.
  /// - Returns: `nil` if this is the first resume call, or the result from the
  ///   previous resume call if the continuation was already resumed.
  ///
  /// ## Example
  /// ```swift
  /// if let previousResult = continuation.resume(throwing: error) {
  ///   // Continuation was already resumed with previousResult
  ///   print("Warning: attempted to resume continuation twice")
  /// }
  /// ```
  @inlinable
  @discardableResult
  public consuming func resume(
    throwing error: any Error
  ) -> sending Result<Success, any Error>? {
    resume(with: .failure(error))
  }

  /// Resumes the continuation with a result.
  ///
  /// This method can only be called once. Subsequent calls are ignored but return
  /// the result from the first resume call.
  ///
  /// - Parameter result: The result to deliver to the awaiting code.
  /// - Returns: `nil` if this is the first resume call, or the result from the
  ///   previous resume call if the continuation was already resumed.
  ///
  /// ## Example
  /// ```swift
  /// if let previousResult = continuation.resume(with: .success(value)) {
  ///   // Continuation was already resumed with previousResult
  ///   print("Warning: attempted to resume continuation twice")
  /// }
  /// ```
  @inlinable
  @discardableResult
  public consuming func resume(
    with result: consuming sending Result<Success, any Error>
  ) -> sending Result<Success, any Error>? {
    state.withLock { [result = consume result] in
      $0.resume(with: result)
    }
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
