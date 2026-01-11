# Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) to automate versioning and changelog generation.

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `docs` | Documentation only | Patch |
| `style` | Code style (formatting) | Patch |
| `refactor` | Code refactoring | Patch |
| `perf` | Performance improvement | Patch |
| `test` | Adding/fixing tests | Patch |
| `chore` | Maintenance tasks | Patch |
| `ci` | CI/CD changes | Patch |

## Scopes (Optional)

Use module names as scopes:

- `Either`
- `SequenceBuilder`
- `StdPlus`
- `Box`
- `AsyncPlus`
- `IO`

## Breaking Changes

Add `!` after type or include `BREAKING CHANGE:` in footer for major version bump:

```
feat(Either)!: remove deprecated fold method

BREAKING CHANGE: The fold method signature has changed.
```

## Examples

```
feat(StdPlus): add clamped() extension for numeric types

fix(AsyncPlus): resolve race condition in SaferContinuation

docs: update README with new module descriptions

chore: update Swift tools version to 6.2

feat(Box)!: rename MutexBox to SyncBox

BREAKING CHANGE: MutexBox has been renamed to SyncBox for clarity.
```
