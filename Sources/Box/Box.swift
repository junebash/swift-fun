import Synchronization

/// An immutable reference wrapper for a value.
///
/// `Box` provides reference semantics for any value, including non-copyable types.
/// This is useful when you need to share a value without copying, or when you need
/// to store a non-copyable value in a context that requires a reference type.
///
/// ```swift
/// let boxedValue = Box(expensiveComputation())
/// // boxedValue can be passed around by reference
/// print(boxedValue.value)
/// ```
public final class Box<Value: ~Copyable> {
  /// The wrapped value.
  public let value: Value

  /// Creates a box containing the specified value.
  ///
  /// - Parameter value: The value to wrap.
  public init(_ value: consuming Value) {
    self.value = value
  }
}

extension Box: Sendable where Value: Sendable {}

/// A thread-safe mutable reference wrapper for a value.
///
/// `MutexBox` provides synchronized access to a mutable value using Swift's `Mutex`.
/// All access to the wrapped value goes through `withLock`, ensuring thread safety.
///
/// ```swift
/// let counter = MutexBox(0)
/// counter.withLock { $0 += 1 }
/// ```
public final class MutexBox<Value: ~Copyable>: Sendable {
  @usableFromInline
  let mutex: Mutex<Value>

  /// Creates a mutex box containing the specified value.
  ///
  /// - Parameter value: The initial value to wrap.
  public init(_ value: consuming sending Value) {
    self.mutex = Mutex(value)
  }

  /// Executes a closure with exclusive access to the wrapped value.
  ///
  /// The closure receives an `inout` reference to the value, allowing both
  /// reading and mutation. Access is synchronized, so only one thread can
  /// access the value at a time.
  ///
  /// ```swift
  /// let box = MutexBox([1, 2, 3])
  /// box.withLock { $0.append(4) }
  /// ```
  ///
  /// - Parameter body: A closure that receives exclusive access to the value.
  /// - Returns: The result of `body`.
  /// - Throws: Rethrows any error from `body`.
  @inlinable
  public func withLock<Output: ~Copyable, E: Error>(
    _ body: (inout sending Value) throws(E) -> sending Output
  ) throws(E) -> sending Output {
    try mutex.withLock(body)
  }
}

extension MutexBox where Value: ~Copyable & Sendable {
  /// Replaces the wrapped value and returns the previous value.
  ///
  /// - Parameter value: The new value to store.
  /// - Returns: The previous value.
  @discardableResult
  @inlinable
  public func setValue(_ value: consuming Value) -> Value {
    mutex.withLock {
      swap(&$0, &value)
    }
    return value
  }

  /// Removes and returns the wrapped optional value.
  ///
  /// Sets the wrapped value to `nil` and returns the previous value.
  /// Only available when `Value` is an optional type.
  ///
  /// - Returns: The previous value, or `nil` if it was already `nil`.
  @inlinable
  public func take<Wrapped>() -> Wrapped?
  where Value == Wrapped? {
    mutex.withLock { $0.take() }
  }
}

extension MutexBox where Value: Copyable {
  /// The current value, copied out of the mutex.
  ///
  /// This is a convenience for reading the value when you don't need to mutate it.
  /// For mutation or when you need atomic read-modify-write, use `withLock`.
  @inlinable
  public var value: Value {
    mutex.withLock(\.self)
  }
}
