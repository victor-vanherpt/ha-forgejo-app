# Development

Tooling is managed with [mise](https://mise.jdx.dev). Run `mise install` once,
then `mise tasks` to see what's available. Tasks are scripts in
[`mise-tasks/`](../mise-tasks).

| Task | What it does |
| --- | --- |
| `mise run ci [--native]` | Run the CI pipeline locally; do this before pushing |
| `mise run lint` | hadolint, shellcheck, yamllint, actionlint, translation keys |
| `mise run lint:app` | Home Assistant's app linter, same release as CI (needs Docker) |
| `mise run build [arch]` | Build `local/forgejo:<arch>` for `aarch64` or `amd64` |
| `mise run test [image] [--db sqlite3\|postgres\|mysql]` | Smoke test an image (default `local/forgejo:<host arch>`) against a mocked Supervisor |
| `mise run forgejo:pin [version]` | Pin Forgejo to the latest stable release (or `version`), update checksums and architectures, then bump |
| `mise run bump` | Set the app version for the next commit on `main` |
| `mise run version:check [--base ref]` | Check the version and changelog (CI runs this) |
| `mise run version:pr <number>` | Print a PR's prerelease version (see [CI](ci.md#pr-prereleases)) |

## Before pushing

`mise run ci` runs the same checks as [CI](ci.md), everything except
publishing: lint, the app linter, the version check, and a build and smoke test
per architecture. Architectures other than your machine's are emulated, which
is slow; `--native` skips them.

## Versions

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

## Updating Forgejo

`mise run forgejo:pin` pins the latest stable Forgejo release;
`mise run forgejo:pin 16.0.6` pins a specific one. It updates the version and
checksums in `forgejo/Dockerfile`, then bumps the app version.

The architectures follow what Forgejo publishes, limited to those Home
Assistant supports (`aarch64`, `amd64`), and are written to
`forgejo/config.yaml`.
