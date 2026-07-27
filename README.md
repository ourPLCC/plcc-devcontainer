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
- `feat:` **with a `BREAKING CHANGE:` footer** — major release
- `ci:`, `docs:`, `chore:`, `test:`, `refactor:` — no release

Write the footer, not `feat!:`. semantic-release uses the Angular preset,
which does not parse the `!` shorthand: a `feat!:` subject with no footer
matches nothing and produces **no release at all**, which is easy to miss
because the pipeline still goes green. The `BREAKING CHANGE:` footer is what
actually triggers a major.

If you squash-merge a major, make sure the footer survives into the squash
commit body — with it dropped, the release silently downgrades to a minor.

### Automated PLCC updates

A weekly workflow checks for new PLCC releases and opens a PR automatically. If you see a PR like `fix: update PLCC to vX.Y.Z`, review the CI results and merge if green.

### Release setup

The release and PLCC-update workflows need two repository secrets, `APP_ID` and `APP_PRIVATE_KEY`, belonging to the **ourPLCC Release Bot** GitHub App. Each run mints its own short-lived installation token. This is required because `GITHUB_TOKEN` cannot push to the protected `main` branch.

The App also needs, per repository:
- Contents and Pull requests set to **Read and write**
- Installation access granted to this repository — org-level installation does not cover new repos automatically
- A place in the `main` ruleset's bypass list, which only becomes selectable once repository access is granted

An earlier setup used a static `RELEASE_TOKEN` PAT. That is no longer referenced by any workflow and can be deleted. It is worth knowing why it was replaced: a PAT gives no expiry signal, so when it lapsed nothing surfaced until the next push to main failed at checkout, months later.
