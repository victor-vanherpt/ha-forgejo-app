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
| `mise run lint` | hadolint, shellcheck, yamllint, actionlint, translation keys |
| `mise run build [arch]` | Build `local/forgejo:latest` for `aarch64` or `amd64` |
| `mise run test [image] [--db sqlite3\|postgres\|mysql]` | Smoke test an image against a mocked Supervisor |

Tasks are scripts in [`mise-tasks/`](mise-tasks).

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

[`.github/workflows/ci.yaml`](.github/workflows/ci.yaml) runs on every PR and on
`main`:

1. **Lint**: `mise run lint` and the Home Assistant app linter
2. **Version**: `mise run version:check`
3. **Build**: per architecture on native runners, then smoke tests (SQLite on
   both, PostgreSQL and MariaDB on amd64)
4. **Release** (`main` only): push the images, publish the multi-arch manifest
   to `ghcr.io/victor-vanherpt/ha-forgejo-app` and create the GitHub release

### Repository settings

- After the first release, make the `ha-forgejo-app` package public
  (GitHub → Packages → Package settings), or Home Assistant can't pull it.
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
