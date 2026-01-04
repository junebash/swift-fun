# swift-fun Releases

## v0.2.0

### New Modules

- **Box**: Reference wrappers for values, including thread-safe `MutexBox` using Swift 6's `Synchronization.Mutex`
- **AsyncPlus**: Concurrency utilities including `SaferContinuation` for leak-safe continuations and `ScaledClock` for time-scaled testing

### StdPlus Additions

**New Functions:**
- Free functions: `with()`, `configure()`, `catchAndReturn()` (with async variants)

**New Sequence Extensions:**
- `only` property for extracting a single element from a sequence

**Optional Enhancements:**
- Made `UnwrapError` generic for better type precision
- Added `takeOrThrow()` (mutating) to consume optional values
- Added async `map()` and `flatMap()` for async transformations

**Numeric Extensions:**
- `clamped()` to constrain values to a range
- `nonZero()` to filter out zero values
- `positive()` to filter for positive values only

**StatefulAsyncSequence:**
- Added `Sendable` initializer variant for sendable state

---

## v0.1.0

### Modules

- **Either**: A sum type representing one of two possible values, with full support for non-copyable types
  - APIs: `map`, `flatMap`, `mapLeft`, `bimap`, `fold`, `swapped`, `separated`

- **SequenceBuilder**: A result builder for declarative sequence construction
  - Works with any `RangeReplaceableCollection` or `SetAlgebra` type

- **StdPlus**: Ergonomic extensions to Swift standard library types
  - **Collection Extensions**: `nonEmpty` property
  - **Optional Extensions**: `orThrow()` for unwrapping with custom errors
  - **Numeric Extensions**: `isNearEqual()` for floating-point comparison
  - **Duration Extensions**: `timeInterval` conversion
  - **Async Sequences**: `StatefulAsyncSequence` for async sequences with mutable state
