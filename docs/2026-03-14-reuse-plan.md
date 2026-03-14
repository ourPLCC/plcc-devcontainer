# REUSE Compliance Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add REUSE compliance to `plcc-devcontainer`, replacing the MIT `LICENSE` file with GPL-3.0-or-later (code) and GFDL-1.3-or-later (docs).

**Architecture:** Create `scripts/reuse.sh` (Docker wrapper for `fsfe/reuse`), use it to download license texts into `LICENSES/`, add `REUSE.toml` with catch-all GPL and GFDL override for docs, and add SPDX headers to all commentable files.

**Tech Stack:** REUSE tool (`fsfe/reuse` Docker image), TOML, Bash, YAML

---

## Chunk 1: scripts/reuse.sh and license download

### Task 1: Create `scripts/reuse.sh`

**Files:**
- Create: `scripts/reuse.sh`

All commands in this plan are run from the `tmp/plcc-devcontainer/` directory.

- [ ] **Step 1: Create the scripts directory and wrapper**

```bash
mkdir -p scripts
```

Create `scripts/reuse.sh` with this exact content:

```bash
#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later

# REUSE wrapper script
# Runs REUSE tool from Docker container with current directory mounted as /data

docker run --rm --volume "$(pwd):/data" fsfe/reuse "$@"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/reuse.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/reuse.sh
git commit -m "chore: add scripts/reuse.sh wrapper"
```

---

### Task 2: Download license texts

**Files:**
- Create: `LICENSES/GPL-3.0-or-later.txt`
- Create: `LICENSES/GFDL-1.3-or-later.txt`

- [ ] **Step 1: Download the licenses**

```bash
./scripts/reuse.sh download GPL-3.0-or-later GFDL-1.3-or-later
```

Expected: two files appear under `LICENSES/`:
```
LICENSES/GPL-3.0-or-later.txt
LICENSES/GFDL-1.3-or-later.txt
```

- [ ] **Step 2: Remove the old MIT LICENSE file**

```bash
git rm LICENSE
```

- [ ] **Step 3: Commit**

```bash
git add LICENSES/
git commit -m "chore: add GPL-3.0-or-later and GFDL-1.3-or-later license texts, remove MIT LICENSE"
```

---

## Chunk 2: REUSE.toml and SPDX headers

### Task 3: Create `REUSE.toml`

**Files:**
- Create: `REUSE.toml`

- [ ] **Step 1: Create REUSE.toml**

Create `REUSE.toml` with this exact content:

```toml
version = 1
SPDX-PackageName = "plcc-devcontainer"
SPDX-PackageSupplier = "Organization: ourPLCC"
SPDX-PackageDownloadLocation = "NOASSERTION"

[[annotations]]
path = ["**"]
precedence = "closest"
SPDX-FileCopyrightText = "2026 ourPLCC contributors"
SPDX-License-Identifier = "GPL-3.0-or-later"

[[annotations]]
path = [
    "README.md",
    "CLAUDE.md",
    "CODE_OF_CONDUCT.md",
    "docs/**"
]
precedence = "override"
SPDX-FileCopyrightText = "2026 ourPLCC contributors"
SPDX-License-Identifier = "GFDL-1.3-or-later"
```

- [ ] **Step 2: Commit**

```bash
git add REUSE.toml
git commit -m "chore: add REUSE.toml"
```

---

### Task 4: Add SPDX headers to shell scripts

> Note: `scripts/reuse.sh` also requires an SPDX header, but it is included in its
> initial file content in Task 1 (Chunk 1) and does not need to be modified here.

**Files:**
- Modify: `test/test-env.sh`
- Modify: `.devcontainer/features/plcc/install.sh`

- [ ] **Step 1: Add header to `test/test-env.sh`**

Insert these two lines immediately after the `#!/bin/bash` shebang (line 1):

```bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
```

The file should begin:

```bash
#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Smoke test: verifies the devcontainer environment has all required tools.
```

- [ ] **Step 2: Add header to `.devcontainer/features/plcc/install.sh`**

Insert these two lines immediately after the `#!/bin/bash` shebang (line 1):

```bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
```

The file should begin:

```bash
#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Installs PLCC into /usr/local/lib/plcc.
```

- [ ] **Step 3: Commit**

```bash
git add test/test-env.sh .devcontainer/features/plcc/install.sh
git commit -m "chore: add SPDX headers to shell scripts"
```

---

### Task 5: Add SPDX headers to GitHub Actions workflows

**Files:**
- Modify: `.github/workflows/check-plcc-release.yml`
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/release.yml`

For YAML files, SPDX headers go as `#` comments at the very top of the file (before any YAML content).

- [ ] **Step 1: Add header to `check-plcc-release.yml`**

Prepend these two lines to the top of the file:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
```

The file should begin:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
name: Check PLCC Release
```

- [ ] **Step 2: Add header to `ci.yml`**

Prepend these two lines to the top of the file:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
```

The file should begin:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
name: CI
```

- [ ] **Step 3: Add header to `release.yml`**

Prepend these two lines to the top of the file:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
```

The file should begin:

```yaml
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
name: Release
```

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/
git commit -m "chore: add SPDX headers to GitHub Actions workflows"
```

---

## Chunk 3: Verification

### Task 6: Verify REUSE compliance

- [ ] **Step 1: Run `reuse lint`**

```bash
./scripts/reuse.sh lint
```

Expected output ends with:

```
Congratulations! Your project is compliant with version 3.3 of the REUSE Specification :-)
```

If there are errors, they will identify which files are missing copyright/license information. Fix each file by either adding an SPDX header (if the file format supports comments) or adding an explicit `[[annotations]]` entry in `REUSE.toml` for that path.

- [ ] **Step 2: Commit fix (only if lint found issues)**

```bash
git add <fixed files>
git commit -m "chore: fix REUSE compliance issues"
```

Re-run `./scripts/reuse.sh lint` until it passes before moving on.

- [ ] **Step 3: Final commit if everything passed on first try**

No additional commit needed — all changes are already committed in prior tasks.

---

### Task 7: Track stale OCI license label

The `org.opencontainers.image.licenses` label in two workflow files still reads `"MIT"`.
This is a known follow-on item (out of scope for REUSE compliance itself, but must not be forgotten).

**Files:**
- Modify: `.github/workflows/ci.yml` (line 48)
- Modify: `.github/workflows/release.yml` (line 67)

- [ ] **Step 1: Add TODO comments to the stale label lines**

In `.github/workflows/ci.yml`, change line 48 from:

```yaml
            "MIT" \
```

to:

```yaml
            "MIT" \  # TODO: update to GPL-3.0-or-later after REUSE migration
```

In `.github/workflows/release.yml`, change line 67 from:

```yaml
            "MIT" "$PLCC_VERSION" \
```

to:

```yaml
            "MIT" "$PLCC_VERSION" \  # TODO: update to GPL-3.0-or-later after REUSE migration
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml .github/workflows/release.yml
git commit -m "chore: mark stale MIT OCI label for follow-on update"
```
