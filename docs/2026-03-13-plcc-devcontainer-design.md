# plcc-devcontainer Design

**Date:** 2026-03-13
**Project:** https://github.com/ourPLCC/plcc-devcontainer

## Overview

A new GitHub repository whose primary purpose is to produce and publish a prebuilt Docker container image containing PLCC, Java, and Python — for use by courses and assignments running on GitHub Codespaces or VS Code devcontainers. Its secondary purpose is to document and model how a downstream project (e.g. a student assignment repo) configures its devcontainer to use this image.

## Background

PLCC (Programming Language Compiler Compiler) is an educational tool used by faculty and students to learn about programming language implementation. Projects like [CCSCNE-2026](https://github.com/ourPLCC/CCSCNE-2026) use a devcontainer to provide a consistent PLCC environment. The CCSCNE-2026 devcontainer is broken: it installs PLCC via a VSCode task that fires on folder-open (unreliably), rather than at container build time.

## Goals

- Provide a prebuilt devcontainer image with PLCC, Java 17, and Python 3.11 pre-installed
- Publish the image to GHCR with stable, predictable versioning
- Automate PLCC version updates without requiring manual intervention
- Serve as a clear model for downstream projects adopting the image
- Lay the groundwork for a publishable devcontainer Feature in the future

## Non-Goals

- Publishing a devcontainer Feature (deferred; local feature structure makes it easy later)
- Providing a GitHub template repository (deferred; README documentation is sufficient for now)
- Supporting tools beyond PLCC, Java, and Python (no Node, no IDE extensions in the image)

## Repository Structure

```
plcc-devcontainer/
├── .devcontainer/
│   ├── devcontainer.json       # base:ubuntu + java + python + local plcc feature
│   └── features/
│       └── plcc/
│           ├── devcontainer-feature.json
│           └── install.sh
├── .github/
│   └── workflows/
│       ├── ci.yml              # PR: build image, push as pr-{N}, post comment
│       ├── release.yml         # push to main: semantic-release, push versioned tags
│       └── check-plcc-release.yml  # weekly: detect new PLCC release, open PR
├── .releaserc.json             # semantic-release configuration
├── devcontainer.json           # downstream template (documentation artifact, linked from README)
└── README.md
```

## devcontainer Configuration

### `.devcontainer/devcontainer.json` (build recipe — dogfoods itself)

The repo's own devcontainer always builds from the recipe. VS Code and Codespaces use this file (not the root-level `devcontainer.json`). It serves as a live test of the install logic and demonstrates what CI materializes into the published image.

```json
{
  "name": "PLCC",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
  "features": {
    "ghcr.io/devcontainers/features/java:1": { "version": "17" },
    "ghcr.io/devcontainers/features/python:1": { "version": "3.11" },
    "./features/plcc": { "version": "v2.1.0" }
  }
}
```

The PLCC version value (e.g. `v2.1.0`) is the only thing the automated update workflow changes. All PLCC version references use the `v`-prefixed tag format to match the PLCC repo's release tags.

### `devcontainer.json` (project root — downstream template)

A documentation artifact only — VS Code and Codespaces do not use this file (`.devcontainer/devcontainer.json` takes precedence). It is the minimal template for downstream projects, shown in the README. It pins to a major tag for stability. The file should include a comment at the top explaining its purpose so contributors are not confused by having two `devcontainer.json` files in the repo.

```jsonc
// Template for downstream projects. Copy this file to your project's
// .devcontainer/devcontainer.json and adjust as needed.
// This file is NOT used by this repository's own devcontainer.
{
  "name": "My PLCC Project",
  "image": "ghcr.io/ourplcc/plcc-devcontainer:1"
}
```

If multiple template variants emerge (e.g. student vs. instructor), this file moves into a `templates/` directory with subdirectories per variant.

## Local PLCC Feature

### `.devcontainer/features/plcc/devcontainer-feature.json`

The `version` field here is the version of the feature definition schema itself, not the PLCC version being installed. It is incremented independently when the feature's metadata or install logic changes.

The `containerEnv` block is how the devcontainer runtime makes PLCC available in all shell types — including non-login, non-interactive shells used by VS Code tasks and lifecycle scripts (e.g. `postCreateCommand`). This is the preferred mechanism; `/etc/profile.d/` alone is not sufficient for non-login shells.

Note: `${PATH}` interpolation in `containerEnv` is not guaranteed by all devcontainer runtime versions. As a belt-and-suspenders fallback, `install.sh` also appends to `/etc/environment` (which is unconditionally sourced in all shell contexts):

```bash
echo 'PATH=/usr/local/lib/plcc/src/plcc/bin:'"$PATH" >> /etc/environment
```

```json
{
  "id": "plcc",
  "version": "1.0.0",
  "name": "PLCC",
  "description": "Installs PLCC (Programming Language Compiler Compiler)",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Git tag of PLCC to install, using the v-prefixed format (e.g. 'v2.1.0'). Use 'latest' for the default branch."
    }
  },
  "containerEnv": {
    "PATH": "/usr/local/lib/plcc/src/plcc/bin:${PATH}"
  }
}
```

### `.devcontainer/features/plcc/install.sh`

The script runs as root during image build. PLCC is installed to `/usr/local/lib/plcc` (a system path) so it is accessible to the non-root `vscode` user that runs inside the container.

```bash
#!/bin/bash
set -e
VERSION=${VERSION:-latest}

apt-get update && apt-get install -y --no-install-recommends git
rm -rf /var/lib/apt/lists/*

if [ "$VERSION" = "latest" ]; then
    git clone --depth 1 --single-branch https://github.com/ourPLCC/plcc /usr/local/lib/plcc
else
    git clone --depth 1 --single-branch --branch "$VERSION" https://github.com/ourPLCC/plcc /usr/local/lib/plcc
fi

# Belt-and-suspenders: /etc/environment is sourced in all shell contexts,
# including non-login shells where containerEnv ${PATH} interpolation may not work.
echo 'PATH=/usr/local/lib/plcc/src/plcc/bin:'"$PATH" >> /etc/environment
```

This install script (`.devcontainer/features/plcc/install.sh`) is the core of a future publishable devcontainer Feature. To publish it later: move to `src/plcc/`, adjust metadata, run `devcontainer features publish`.

## CI/CD Pipelines

All workflows require the following GitHub Actions permissions configured at the repository level or in the workflow file:
- `packages: write` — to push images to GHCR
- `contents: write` — to create releases and tags
- `pull-requests: write` — to post PR comments and open PRs

### Building with the `devcontainer` CLI

All image builds use:

```bash
devcontainer build --workspace-folder . --image-name <tag>
```

Running from the repository root ensures that local feature references (e.g. `.devcontainer/features/plcc`) resolve correctly relative to the workspace.

OCI image labels cannot be attached directly via `devcontainer build`. They are applied as a separate step: the workflow generates a minimal `Dockerfile.labels` at build time and runs `docker buildx build` to produce the final tagged image:

```bash
# Example of what the workflow generates and runs:
printf 'FROM %s\nLABEL org.opencontainers.image.version="%s"\nLABEL org.opencontainers.image.source="%s"\nLABEL org.opencontainers.image.description="%s"\nLABEL org.opencontainers.image.licenses="%s"\nLABEL org.plcc.version="%s"\n' \
  "$INTERMEDIATE_IMAGE" "$IMAGE_VERSION" "$SOURCE_URL" "$DESCRIPTION" "$LICENSE" "$PLCC_VERSION" \
  > Dockerfile.labels
docker buildx build -f Dockerfile.labels -t "$FINAL_TAG" .
```

Additional standard OCI labels to include: `org.opencontainers.image.source` (repo URL), `org.opencontainers.image.description`, and `org.opencontainers.image.licenses`. These link the GHCR package to the repository in the GitHub UI.

`Dockerfile.labels` is generated at build time and must be listed in `.gitignore` to prevent accidental commits.

### `ci.yml` — Pull Request

Triggers on every PR.

1. Build image using `devcontainer build --workspace-folder . --image-name ghcr.io/ourplcc/plcc-devcontainer:pr-${PR_NUMBER}`
2. Apply OCI labels via wrapper build
3. Push to GHCR
4. Post a comment on the PR with the image tag for manual testing

### `release.yml` — Release

Triggers on push to `main`. Uses a GitHub App token (preferred for auditability and secret rotation) or a repository PAT rather than `GITHUB_TOKEN`, because `GITHUB_TOKEN` cannot push release commits and tags to a protected `main` branch. The token must be stored as a repository secret (e.g. `RELEASE_TOKEN`). Minimum PAT scopes required: `contents: write` and `packages: write`.

1. Run semantic-release to determine version bump and capture the new version number — the image build must not begin until this step completes, because `org.opencontainers.image.version` depends on the version semantic-release determines. Semantic-release also creates the GitHub release and CHANGELOG entry.
2. Read current PLCC version from `.devcontainer/devcontainer.json`:
   ```bash
   jq -r '.features["./features/plcc"].version' .devcontainer/devcontainer.json
   ```
3. Build image using `devcontainer build`
4. Apply OCI labels via generated `Dockerfile.labels` build:
   - `org.opencontainers.image.version` — image version (e.g. `1.2.3`)
   - `org.opencontainers.image.source` — repository URL
   - `org.opencontainers.image.description` — short description
   - `org.opencontainers.image.licenses` — license identifier
   - `org.plcc.version` — PLCC version installed (e.g. `v2.1.0`)
5. Push with floating tags: `latest`, `{major}`, `{major}.{minor}`, `{major}.{minor}.{patch}`

The first release is bootstrapped by cutting an initial `1.0.0` release manually (or by pushing a `feat!:` commit to trigger semantic-release's initial release).

### `check-plcc-release.yml` — PLCC Version Check

Triggers on a weekly schedule.

1. Fetch latest release tag from `https://api.github.com/repos/ourPLCC/plcc/releases/latest`
2. Extract the current version from `.devcontainer/devcontainer.json` using `jq`:
   ```bash
   jq -r '.features["./features/plcc"].version' .devcontainer/devcontainer.json
   ```
3. If the versions match, exit — no action needed (idempotent)
4. If a branch named `chore/update-plcc-{version}` already exists, exit — PR already open. Note: the branch existence check and branch creation are not atomic; if the workflow runs twice in quick succession, the second branch push will fail. The workflow should treat a failed push as a no-op (`|| true`) and exit cleanly.
5. Otherwise, create a branch, update the version using `jq`, and open a PR with commit:
   ```
   fix: update PLCC to v2.2.0
   ```
6. CI runs on the PR; maintainer merges if green — merging triggers `release.yml`, which builds and publishes a new versioned image automatically

`main` is a protected branch. No direct pushes. All changes go through PRs, ensuring broken builds never land on `main`.

## Versioning

Managed by semantic-release with Conventional Commits:

| Commit type | Version bump | Example |
|---|---|---|
| `fix:` | patch | `1.2.3` → `1.2.4` |
| `feat:` | minor | `1.2.x` → `1.3.0` |
| `BREAKING CHANGE:` | major | `1.x.x` → `2.0.0` |

Published image tags follow the floating tag pattern used by official Docker images:

- `latest` — always the most recent release
- `1` — latest release in the `1.x.x` line
- `1.2` — latest release in the `1.2.x` line
- `1.2.3` — exact release (immutable)

Downstream courses should pin to a major tag (e.g. `1`) for stability — they get patch updates automatically but are protected from breaking changes.

## Documentation

`README.md` covers:

1. What this project is and who it's for
2. Quick start — minimal `devcontainer.json` for a downstream project
3. Tag pinning — explanation of the versioning scheme and recommendation to pin to `{major}`
4. What's included — current PLCC, Java, and Python versions
5. Contributing — how to open a PR, how automated PLCC update PRs work, how to test using a `pr-{N}` image tag

The CHANGELOG is generated automatically by semantic-release.

## Future Work

- **Publishable devcontainer Feature** — `.devcontainer/features/plcc/install.sh` is ~90% of a publishable Feature; extraction requires moving to `src/plcc/`, adjusting metadata, and adding a publish workflow
- **Template variants** — if downstream project types diverge (e.g. student vs. instructor), introduce a `templates/` directory
