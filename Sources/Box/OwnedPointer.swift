/// A heap-allocated container that maintains unique ownership of its value.
///
/// Use `OwnedPointer` when you need heap allocation with move-only semantics.
/// Unlike `Shared`, which provides shared reference semantics, `OwnedPointer`
/// ensures exactly one owner exists at any time while still storing the value
/// on the heap.
///
/// This is useful when:
/// - You need a stable memory address for a value (e.g., for C interop)
/// - You want heap allocation without giving up unique ownership
/// - You're working with non-copyable types that must live on the heap
///
/// The wrapped value is automatically deallocated when the `OwnedPointer` is
/// consumed or goes out of scope.
@safe
public struct OwnedPointer<Value: ~Copyable>: ~Copyable {
  private let pointer: UnsafeMutablePointer<Value>

  /// Provides direct access to the wrapped value for reading and mutation.
  public var value: Value {
    _read { yield unsafe pointer.pointee }
    _modify { yield unsafe &pointer.pointee }
  }

  /// Creates an owned pointer by moving the value to the heap.
  public init(_ value: consuming Value) {
    let pointer = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    unsafe pointer.initialize(to: value)
    unsafe self.pointer = pointer
  }

  deinit {
    unsafe pointer.deinitialize(count: 1)
    unsafe pointer.deallocate()
  }
}
