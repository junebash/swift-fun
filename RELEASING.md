# Releasing swift-fun

This document describes the release process for swift-fun.

## Overview

Releases are created locally using:

- **Conventional Commits** for semantic versioning
- **git-cliff** for changelog generation
- **Claude Code** (optional) for human-readable release notes
- **GitHub Actions** automatically creates GitHub Releases when tags are pushed

## Version Bumping

Versions are automatically determined from commit messages:

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `fix:` | Patch (0.0.x) | `fix(StdPlus): correct edge case in clamped()` |
| `feat:` | Minor (0.x.0) | `feat(Box): add SyncBox type` |
| `BREAKING CHANGE` or `!:` | Major (x.0.0) | `feat(Either)!: remove deprecated API` |

See [.github/COMMIT_CONVENTION.md](.github/COMMIT_CONVENTION.md) for full commit guidelines.

## Creating a Release

### Prerequisites

```bash
# Install git-cliff
brew install git-cliff

# Optional: Install gh CLI for GitHub releases
brew install gh
```

### Release Workflow

```bash
# 1. Dry run to see what will happen
./scripts/release.sh --dry-run

# 2. Create release (will prompt for confirmation)
./scripts/release.sh

# 3. Or create and push in one step
./scripts/release.sh --push
```

The script will:

1. Detect the next version from commits
2. Generate changelog with git-cliff
3. Enhance notes with Claude Code (if available)
4. Show you the changelog and ask for confirmation
5. Update RELEASES.md
6. Create git commit and tag
7. Optionally push and create GitHub release

### Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would happen without making changes |
| `--version X.Y.Z` | Override automatic version detection |
| `--push` | Push commits/tags and create GitHub release |
| `--skip-enhance` | Use raw git-cliff output without Claude enhancement |

### Examples

```bash
# See what the next release would look like
./scripts/release.sh --dry-run

# Create a patch release
./scripts/release.sh

# Create a specific version
./scripts/release.sh --version 1.0.0

# Quick release without Claude enhancement
./scripts/release.sh --skip-enhance --push

# Full automated release with Claude
./scripts/release.sh --push
```

## GitHub Actions

When you push a tag (e.g., `git push origin v1.0.0`), GitHub Actions will automatically:

1. Extract release notes from RELEASES.md
2. Create a GitHub Release with those notes

No secrets or API keys required.

## File Structure

```
swift-fun/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml           # Build and test on push/PR
│   │   └── release.yml      # Create GitHub Release on tag push
│   └── COMMIT_CONVENTION.md # Commit message guidelines
├── scripts/
│   ├── determine-version.sh # Semantic version detection
│   ├── update-releases.sh   # RELEASES.md updater
│   └── release.sh           # Main release script
├── cliff.toml               # git-cliff configuration
├── RELEASES.md              # Release history
└── RELEASING.md             # This file
```

## Troubleshooting

### "No new commits since last tag"

The release was skipped because there are no commits since the last release. Make some changes first.

### Claude Code not found

The script will fall back to showing you a prompt to copy/paste into Claude, or you can use `--skip-enhance` to use the raw git-cliff output.

### git-cliff not found

Install with `brew install git-cliff` (macOS) or see [git-cliff installation](https://git-cliff.org/docs/installation).

### Version not incrementing correctly

Ensure commits follow [Conventional Commits](https://www.conventionalcommits.org/) format. The version detection script looks for `feat:`, `fix:`, and `BREAKING CHANGE` patterns.
