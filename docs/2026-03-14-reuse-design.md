# REUSE Compliance Design

**Date:** 2026-03-14
**Project:** plcc-devcontainer
**Status:** Approved

## Overview

Add REUSE compliance to `plcc-devcontainer`, replacing the existing MIT `LICENSE`
file with GPL-3.0-or-later (code) and GFDL-1.3-or-later (docs), matching the
license scheme used across the common project suite.

## Components

### 1. `scripts/reuse.sh`

A wrapper script (mirroring `scripts/reuse` in the common project) that runs the
`fsfe/reuse` Docker image with the current directory mounted as `/data`.

### 2. License texts (`LICENSES/`)

Downloaded via `scripts/reuse.sh`:
- `LICENSES/GPL-3.0-or-later.txt`
- `LICENSES/GFDL-1.3-or-later.txt`

The existing root `LICENSE` (MIT) is removed.

### 3. `REUSE.toml`

Follows the suite pattern exactly. Package metadata:
- `SPDX-PackageName = "plcc-devcontainer"`
- `SPDX-PackageSupplier = "Organization: ourPLCC"` — intentional; this project is owned by the ourPLCC organization, not an individual
- `SPDX-PackageDownloadLocation = "NOASSERTION"`

Annotations:

| Files | License | Precedence |
|---|---|---|
| `**` (all) | GPL-3.0-or-later | closest |
| `README.md`, `CLAUDE.md`, `CODE_OF_CONDUCT.md`, `docs/**` | GFDL-1.3-or-later | override |

Copyright: `2026 ourPLCC contributors`

Notes:
- `CHANGELOG.md` is left under GPL (catch-all), consistent with all other projects in the suite.
- `CLAUDE.md` and `CODE_OF_CONDUCT.md` do not currently exist but are included in
  the GFDL block so they fall under the correct license if added later.

### 4. SPDX headers

Added to files where inline comments are possible:
- `test/test-env.sh`
- `.devcontainer/features/plcc/install.sh`
- `.github/workflows/check-plcc-release.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `scripts/reuse.sh`

Files covered solely by `REUSE.toml` annotation (no inline header possible or needed):
- `devcontainer.json`
- `.devcontainer/devcontainer.json`
- `.devcontainer/features/plcc/devcontainer-feature.json`
- `.gitignore`
- `.releaserc.json`
- `docs/**`

### 5. Verification

Run `scripts/reuse.sh lint` from within `tmp/plcc-devcontainer/` to confirm
full REUSE compliance.

## Out of Scope

- CI workflow integration for REUSE linting
- Updating the `org.opencontainers.image.licenses` OCI label in `ci.yml` (currently
  `"MIT"`) — this should be addressed as a follow-on once licensing is settled
- Changes to any other project in the suite
