# swift-fun

A collection of functional programming utilities and ergonomic extensions for Swift 6.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/junebash/swift-fun.git", from: "0.1.0")
]
```

Then add the modules you need to your target:

```swift
.target(name: "YourTarget", dependencies: [
  .product(name: "Either", package: "swift-fun"),
  .product(name: "SequenceBuilder", package: "swift-fun"),
  .product(name: "StdPlus", package: "swift-fun"),
  .product(name: "Box", package: "swift-fun"),
  .product(name: "AsyncPlus", package: "swift-fun"),
])
```

## Modules

### Either

A sum type representing one of two possible values, with full support for non-copyable types.

```swift
import Either

let result: Either<Error, User> = fetchUser(id)

// Transform the success value
let name = result.map { $0.name }

// Reduce to a single type
let message = result.fold(
  left: { "Error: \($0)" },
  right: { "Hello, \($0.name)" }
)

// Partition a collection
let (errors, users) = results.separated()
```

Key APIs: `map`, `flatMap`, `mapLeft`, `bimap`, `fold`, `swapped`, `separated`

### SequenceBuilder

A result builder for declarative sequence construction.

```swift
import SequenceBuilder

let items = Array {
  1
  2
  [3, 4, 5]
  if includeMore {
    6
  }
  for n in 7...9 {
    n
  }
}
```

Works with any `RangeReplaceableCollection` or `SetAlgebra` type.

### StdPlus

Ergonomic extensions to Swift standard library types, plus functional utilities.

```swift
import StdPlus

// Unwrap or throw
let user = try users[id].orThrow(UserError.notFound)
var pending = task
let value = try pending.takeOrThrow()  // Consumes the optional

// Conditional unwrapping
let valid = age.filter { $0 >= 0 && $0 <= 150 }

// Non-empty collections
if let items = results.nonEmpty {
  process(items)
}

// Single element sequences
let match = filtered.only  // nil if 0 or 2+ elements

// Numeric utilities
let bounded = value.clamped(to: 0...100)
let nonZero = count.nonZero() ?? 1
let positive = delta.positive()

// Floating-point comparison
if actual.isNearEqual(to: expected, tolerance: 0.001) { ... }

// Functional helpers
let result = with(resource) { process($0) }
let configured = configure(settings) { $0.timeout = 30 }
if let error = catchAndReturn({ try validate(input) }) {
  handle(error)
}

// Async Optional operations
let user = try await userId.map { await fetchUser($0) }

// Duration to TimeInterval
let seconds = duration.timeInterval
```

Also includes `StatefulAsyncSequence` for async sequences with mutable state.

### Box

Reference wrappers for values, including thread-safe mutable access.

```swift
import Box

// Immutable reference wrapper
let boxed = Box(expensiveValue)
share(boxed)  // Pass by reference

// Thread-safe mutable wrapper
let counter = MutexBox(0)
counter.withLock { $0 += 1 }

// Atomic operations
let old = counter.setValue(100)
let value = counter.value  // Thread-safe read
```

`MutexBox` uses Swift 6's `Synchronization.Mutex` for thread-safe access.

### AsyncPlus

Concurrency utilities for safer async code and time manipulation.

```swift
import AsyncPlus

// Leak-safe continuations
let result = try await withSaferContinuation { continuation in
  callback { value in
    continuation.resume(returning: value)
  }
  // If continuation is never resumed, throws LeakedContinuationError
}

// Detect if continuation was already resumed
let result = try await withSaferContinuation { continuation in
  continuation.resume(returning: 42)

  // Second resume returns the previous result instead of nil
  if let previousResult = continuation.resume(returning: 99) {
    print("Warning: continuation was already resumed with \(previousResult)")
  }
}

// Time-scaled clocks for testing
let fastClock = ContinuousClock().scaled(by: 10.0)
try await fastClock.sleep(for: .seconds(10))  // Actually sleeps ~1 second
```

`SaferContinuation` automatically resumes with an error if deallocated without being resumed, preventing the common "continuation leaked" runtime warning. The `resume` methods return `nil` on first call and the previous result on subsequent calls, allowing you to detect and handle double-resume scenarios.

## Requirements

- Swift 6.0+
- iOS 18+ / macOS 15+ / tvOS 18+ / watchOS 11+ / visionOS 2+

## License

MIT
