import Synchronization

/// An immutable reference wrapper for a value.
///
/// `Shared` provides reference semantics for any value, including non-copyable types.
/// This is useful when you need to share a value without copying, or when you need
/// to store a non-copyable value in a context that requires a reference type.
///
/// ```swift
/// let boxedValue = Box(expensiveComputation())
/// // boxedValue can be passed around by reference
/// print(boxedValue.value)
/// ```
public final class Shared<Value: ~Copyable> {
  /// The wrapped value.
  public let value: Value

  /// Creates a box containing the specified value.
  ///
  /// - Parameter value: The value to wrap.
  public init(_ value: consuming Value) {
    self.value = value
  }
}

extension Shared: Sendable where Value: Sendable & ~Copyable {}
