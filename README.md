# Forgejo app for Home Assistant

[![Open your Home Assistant instance and show the add app repository dialog with this repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fvictor-vanherpt%2Fha-forgejo-app)

A Home Assistant app repository with one app:

- **[Forgejo](forgejo/README.md)**: a self-hosted lightweight software forge.

## Development

Tooling is managed with [mise](https://mise.jdx.dev). Run `mise install` once,
then `mise tasks` to see what's available:

| Task | What it does |
| --- | --- |
| `mise run forgejo:pin [version]` | Pin Forgejo to the latest stable release (or `version`), update checksums and architectures, then bump |
| `mise run bump` | Set the app version for the next commit on `main` |
| `mise run version:check [--base ref]` | Check the version and changelog (CI runs this) |
| `mise run version:pr <number>` | Print the PR prerelease version, `<version>-pr-<number>-<commits>-<short sha>` |
| `mise run ci [--native]` | Run the CI pipeline locally; do this before pushing |
| `mise run lint` | hadolint, shellcheck, yamllint, actionlint, translation keys |
| `mise run lint:app` | Home Assistant's app linter, same release as CI (needs Docker) |
| `mise run build [arch]` | Build `local/forgejo:<arch>` for `aarch64` or `amd64` |
| `mise run test [image] [--db sqlite3\|postgres\|mysql]` | Smoke test an image (default `local/forgejo:<host arch>`) against a mocked Supervisor |

Tasks are scripts in [`mise-tasks/`](mise-tasks). `mise run ci` runs the
same checks as CI (everything except publishing): lint, the app linter, the
version check, and a build and smoke test per architecture. Architectures
other than your machine's are emulated, which is slow; `--native` skips them.

### Versions

The app version is `<Forgejo version>-<commit count of main>`, e.g. `17.0.0-42`,
and is used for the image tag, the git tag and the GitHub release.

Every pull request must set the version that `main` will have once the PR is
squash-merged, and describe the change in `forgejo/CHANGELOG.md`:

```sh
mise run bump          # sets forgejo/config.yaml version, adds a changelog heading
$EDITOR forgejo/CHANGELOG.md
```

If another PR is merged first, the **Version** check fails: run `mise run bump`
again and push.

The architectures follow what Forgejo publishes, limited to those Home
Assistant supports (`aarch64`, `amd64`).

### CI

[`.github/workflows/ci.yaml`](.github/workflows/ci.yaml) runs on `main` and on
PRs opened from a branch in this repository (not forks) whose author, and the
user who pushed or re-ran, are allowed: the repository variable `CI_AUTHORS`
(a JSON list of logins, e.g. `["victor-vanherpt", "renovate[bot]"]`), or only
the repository owner when it isn't set. It is triggered by
`pull_request_target`, so it always runs **as defined on `main`**: workflow
changes in a PR don't run until the PR is reviewed and merged (check them with
`mise run ci` before pushing). The PR's code is checked out explicitly.

1. **Lint**: `mise run lint` and the Home Assistant app linter
2. **Version**: `mise run version:check`
3. **Build**: per architecture on native runners, then smoke tests (SQLite on
   both, PostgreSQL and MariaDB on amd64)
4. **Publish**: push the images and the multi-arch manifest to
   `ghcr.io/victor-vanherpt/ha-forgejo-app`
5. **Release** (`main`): GitHub release `<version>` with the changelog notes;
   **Prerelease** (PRs): see below

### PR prereleases

Every push to a PR from this repository publishes a prerelease
`<version>-pr-<number>-<commits>-<short sha>`, e.g. `17.0.0-3-pr-12-004-a8aa8e0`
for the 4th commit of PR #12 (see `mise run version:pr`). The zero-padded
commit count makes a PR's prereleases sort in order; each push is a new version, so Home
Assistant offers it as an update.

- images tagged with that version,
- a `pr/<number>` branch holding just the Home Assistant repository with that
  version, and
- a GitHub prerelease explaining how to install it.

To test a PR in Home Assistant, add
`https://github.com/victor-vanherpt/ha-forgejo-app#pr/<number>` as a repository
and install **Forgejo (PR #n)** from it. Uninstall it and remove the repository
when done. When the PR is merged or closed,
[`pr-cleanup.yaml`](.github/workflows/pr-cleanup.yaml) deletes the prerelease,
the branch and the images. PRs from forks are not built at all.

### Repository settings

- After the first publish (the first PR prerelease), make the
  `ha-forgejo-app`, `aarch64-ha-forgejo-app` and `amd64-ha-forgejo-app`
  packages public (GitHub → Packages → Package settings), or Home Assistant
  can't pull them.
- General → Pull requests: allow **squash merging** only.
- Rulesets for `main`: require a pull request, require the status checks
  **Lint**, **Version**, **Build aarch64** and **Build amd64**, and require
  branches to be up to date before merging.

## License

[MIT](LICENSE), except for the Forgejo logo files (`forgejo/icon.png`,
`forgejo/logo.png`): created by [Caesar Schinas](https://caesarschinas.com/),
licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/),
rendered to PNG from the
[original SVG](https://codeberg.org/forgejo/governance/src/branch/main/branding).
