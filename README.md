# plcc-devcontainer

A prebuilt [devcontainer](https://containers.dev/) image with [PLCC](https://github.com/ourPLCC/plcc), Java 17, and Python 3.11 — for use in courses and assignments on GitHub Codespaces or VS Code.

## Quick Start

Add a `.devcontainer/devcontainer.json` to your project:

```json
{
  "name": "My PLCC Project",
  "image": "ghcr.io/ourplcc/plcc-devcontainer:1"
}
```

Open the project in [GitHub Codespaces](https://codespaces.github.com) or [VS Code with the Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers). PLCC, Java, and Python are ready to use.

A copy of the template above is available in [`devcontainer.json`](./devcontainer.json) at the root of this repository.

## Image Tags

| Tag | Meaning |
|---|---|
| `latest` | Most recent release |
| `1` | Latest `1.x.x` release |
| `1.2` | Latest `1.2.x` release |
| `1.2.3` | Exact release (immutable) |

**Recommendation for courses:** pin to a major tag (e.g. `1`). You get automatic patch updates but are protected from breaking changes mid-semester.

## What's Included

| Tool | Version |
|---|---|
| [PLCC](https://github.com/ourPLCC/plcc) | See [CHANGELOG](./CHANGELOG.md) for current version |
| Java | 17 (OpenJDK) |
| Python | 3.11 |

Commands available: `plccmk`, `scan`, `parse`, `rep`

## Contributing

### Making changes

1. Fork and clone this repository
2. Open it in VS Code or Codespaces — the devcontainer builds from the local recipe
3. Make your changes
4. Open a PR — CI builds the image and tags it `pr-{N}`. To test the built image, temporarily update `.devcontainer/devcontainer.json` to use that tag.

Use [Conventional Commits](https://www.conventionalcommits.org/) in your commit messages:
- `fix:` — patch release
- `feat:` — minor release
- `feat!:` or `BREAKING CHANGE:` — major release

### Automated PLCC updates

A weekly workflow checks for new PLCC releases and opens a PR automatically. If you see a PR like `fix: update PLCC to vX.Y.Z`, review the CI results and merge if green.

### Release setup

The release workflow requires a `RELEASE_TOKEN` repository secret with a GitHub App token (preferred) or a classic PAT. Classic PAT scopes required: `repo`, `write:packages`. This is required because `GITHUB_TOKEN` cannot push to the protected `main` branch.
