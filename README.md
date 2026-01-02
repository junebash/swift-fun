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

Ergonomic extensions to Swift standard library types.

```swift
import StdPlus

// Unwrap or throw
let user = try users[id].orThrow(UserError.notFound)

// Conditional unwrapping
let valid = age.filter { $0 >= 0 && $0 <= 150 }

// Non-empty collections
if let items = results.nonEmpty {
  process(items)
}

// Floating-point comparison
if actual.isNearEqual(to: expected, tolerance: 0.001) { ... }

// Duration to TimeInterval
let seconds = duration.timeInterval
```

Also includes `StatefulAsyncSequence` for async sequences with mutable state.

## Requirements

- Swift 6.0+
- iOS 18+ / macOS 15+ / tvOS 18+ / watchOS 11+ / visionOS 2+

## License

MIT
