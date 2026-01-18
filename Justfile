# swift-fun Justfile

# Default recipe: list available commands
default:
    @just --list

# Build the package
build:
    swift build

# Build in release mode
build-release:
    swift build -c release

# Run all tests
test:
    swift test

# Run tests for a specific module
test-only module:
    swift test --filter {{module}}Tests

# Run tests for AsyncPlus module
test-async:
    swift test --filter AsyncPlusTests

# Run tests for Box module
test-box:
    swift test --filter BoxTests

# Run tests for Either module
test-either:
    swift test --filter EitherTests

# Run tests for SequenceBuilder module
test-sequence:
    swift test --filter SequenceBuilderTests

# Run tests for StdPlus module
test-std:
    swift test --filter StdPlusTests

# Clean build artifacts
clean:
    swift package clean

# Create a release (dry run by default)
release *args:
    ./scripts/release.sh {{args}}

# Create a release (dry run)
release-dry:
    ./scripts/release.sh --dry-run

# Create and push a release
release-push:
    ./scripts/release.sh --push

# Create a release with a specific version
release-version version:
    ./scripts/release.sh --version {{version}}
