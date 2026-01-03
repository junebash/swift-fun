/// Applies a transformation to a value, returning the result.
///
/// A piping function that enables fluent, left-to-right transformations.
/// Supports non-copyable types and typed throws.
///
/// ```swift
/// let result = with(createExpensiveResource()) { resource in
///   process(resource)
/// }
/// ```
///
/// - Parameters:
///   - value: The value to transform.
///   - work: A closure that consumes the value and produces a result.
/// - Returns: The result of `work`.
/// - Throws: Rethrows any error from `work`.
@inlinable
public func with<Value: ~Copyable, E: Error, Output: ~Copyable>(
  _ value: consuming Value,
  do work: (consuming Value) throws(E) -> Output
) throws(E) -> Output {
  try work(value)
}

/// Applies an async transformation to a value, returning the result.
///
/// An async variant of `with` for use with asynchronous transformations.
///
/// ```swift
/// let result = await with(resource) { res in
///   await process(res)
/// }
/// ```
///
/// - Parameters:
///   - value: The value to transform.
///   - work: An async closure that consumes the value and produces a result.
/// - Returns: The result of `work`.
/// - Throws: Rethrows any error from `work`.
@inlinable
public func with<Value: ~Copyable, E: Error, Output: ~Copyable>(
  _ value: consuming Value,
  do work: (consuming Value) async throws(E) -> Output
) async throws(E) -> Output {
  try await work(value)
}

/// Configures a value using a closure and returns the configured value.
///
/// Useful for inline configuration of values, avoiding the need for
/// temporary variables or builder patterns.
///
/// ```swift
/// let view = configure(UILabel()) { label in
///   label.text = "Hello"
///   label.textColor = .red
/// }
/// ```
///
/// - Parameters:
///   - value: The value to configure.
///   - configuration: A closure that mutates the value.
/// - Returns: The configured value.
/// - Throws: Rethrows any error from `configuration`.
@inlinable
public func configure<Value: ~Copyable, E: Error>(
  _ value: consuming Value,
  do configuration: (inout Value) throws(E) -> Void
) throws(E) -> Value {
  try configuration(&value)
  return value
}

/// Executes a throwing closure and returns the error if one is thrown.
///
/// Inverts the typical try-catch pattern when you want the error as a value.
/// Returns `nil` if the closure succeeds.
///
/// ```swift
/// if let error = catchAndReturn({ try validateInput(data) }) {
///   handleValidationError(error)
/// }
/// ```
///
/// - Parameter body: A throwing closure to execute.
/// - Returns: The error thrown by `body`, or `nil` if no error was thrown.
@inlinable
public func catchAndReturn<E: Error>(
  _ body: () throws(E) -> Void
) -> E? {
  do {
    try body()
    return nil
  } catch {
    return error
  }
}

/// Executes an async throwing closure and returns the error if one is thrown.
///
/// An async variant of `catchAndReturn` for use with asynchronous operations.
///
/// ```swift
/// if let error = await catchAndReturn({ try await submitForm(data) }) {
///   await handleSubmissionError(error)
/// }
/// ```
///
/// - Parameter body: An async throwing closure to execute.
/// - Returns: The error thrown by `body`, or `nil` if no error was thrown.
@inlinable
public func catchAndReturn<E: Error>(
  _ body: () async throws(E) -> Void
) async -> E? {
  do {
    try await body()
    return nil
  } catch {
    return error
  }
}
