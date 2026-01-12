# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`swift-fun` is a Swift package exploring functional programming concepts and Swift 6 features, intended as a reusable library. The package is organized into independent modules:

- **Either**: A sum type with `~Copyable` support, typed throws, and functional combinators
- **SequenceBuilder**: Result builder for declarative sequence construction (similar to SwiftUI's ViewBuilder)
- **StdPlus**: Ergonomic extensions to Swift standard library types, plus functional utilities
- **Box**: Reference wrappers for values, including thread-safe `MutexBox`
- **AsyncPlus**: Concurrency utilities including leak-safe continuations and time-scaling clocks

Additional modules will likely be added in the future.

## Building and Testing

```bash
# Build the package
swift build

# Run all tests
swift test

# Run tests for a specific module
swift test --filter EitherTests
swift test --filter SequenceBuilderTests
swift test --filter StdPlusTests
swift test --filter BoxTests
swift test --filter AsyncPlusTests
```

## Architecture

### Module Structure

Each module follows a consistent pattern defined by `addProduct()` in Package.swift:
- Source code in `Sources/{ModuleName}/`
- Tests in `Tests/{ModuleName}Tests/`
- Automatically configured with strict Swift 6 settings

To add a new module, use the `addProduct()` helper:

```swift
addProduct("NewModule", dependencies: ["Either"])  // if dependencies needed
```

### Swift 6 Features in Use

This package heavily leverages cutting-edge Swift 6 features:

- **`~Copyable` types**: `Either` works with non-copyable types
- **Typed throws**: Functions use `throws(E)` instead of generic `throws`
- **Swift 6 language mode**: All targets compile in strict Swift 6 mode
- **Result builders**: `SequenceBuilder` demonstrates advanced result builder patterns
- **Conditional conformance**: Extensive use for `Copyable`, `Sendable`, `Equatable`, etc.

### Code Style

- Use `@inlinable` for performance-critical generic APIs
- Use `@usableFromInline` for implementation details used by inlinable code
- Prefer expression-style switch cases (e.g., `case .left(let x): x` without explicit `return`)
- Conditional conformances should be separate extensions (see `Either.swift:54-57`)
- Keep modules focused and independent where possible

## Git Workflow

### Branches

- Main branch is `develop`
- Create feature branches for larger changes

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body with details]
```

**Types:** `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `ci`

**Scopes:** Module names (`Either`, `Box`, `StdPlus`, `AsyncPlus`, `SequenceBuilder`)

**Examples:**

```
feat(Box): add OwnedPointer for unique ownership semantics

fix(AsyncPlus): resolve race condition in SaferContinuation

refactor(Box): rename Box to MutexBox

feat(Either)!: remove deprecated API

BREAKING CHANGE: The fold method has been removed.
```

Put important details in the commit body—the release script feeds full commit messages to Claude for changelog generation.

See [.github/COMMIT_CONVENTION.md](.github/COMMIT_CONVENTION.md) for full guidelines.

## Releasing

Run `./scripts/release.sh` to create releases. The script:

1. Detects next version from commit types (`feat` → minor, `fix` → patch, `!` → major)
2. Generates changelog with git-cliff
3. Enhances notes with Claude Code
4. Updates RELEASES.md and creates git tag

Options: `--dry-run`, `--push`, `--skip-enhance`, `--version X.Y.Z`

See [RELEASING.md](RELEASING.md) for full documentation.
