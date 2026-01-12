@safe
public struct OwnedPointer<Value: ~Copyable>: ~Copyable {
  private let pointer: UnsafeMutablePointer<Value>

  public var value: Value {
    _read { yield unsafe pointer.pointee }
    _modify { yield unsafe &pointer.pointee }
  }

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
