# CI

[`ci.yaml`](../.github/workflows/ci.yaml) runs on pushes to `main` and on
every PR. PRs run their own copy of the workflow, so workflow changes are
tested in the PR itself. Check them locally first with `mise run ci` (see
[Development](development.md#before-pushing)).

## Jobs

1. **Lint**: `mise run lint` and the Home Assistant app linter.
2. **Version**: `mise run version:check`.
3. **Build**: per architecture on native runners, then smoke tests (SQLite on
   both, PostgreSQL and MariaDB on amd64).
4. **Publish**: pushes the images and the multi-arch manifest to
   `ghcr.io/victor-vanherpt/ha-forgejo-app`.
5. **Release** (`main`): GitHub release `<version>` with the changelog notes,
   the image digests, how to verify the images' cosign signature, and the
   upstream Forgejo checksums (`mise run release:notes`).
   **Prerelease** (PRs): see [PR prereleases](#pr-prereleases).
6. **CI result**: fails unless every job that should have run succeeded. It is
   the only required status check, so a skipped, rejected or failed run never
   counts as passing.

## Who can run CI

- **Branches in this repository** (only people with write access can push
  them) run straight away, with permission to publish prereleases.
- **PRs from forks** only run after you approve them (the run shows
  **Approve and run workflows**; see
  [Repository settings](repository-settings.md)). **Review the diff first,
  including any workflow changes**: the run executes the PR's code and its copy
  of the workflow. Fork runs get a read-only token, so they build and test but
  publish no prerelease.

## PR prereleases

Every push to a PR from a branch in this repository publishes a prerelease
`<version>-pr-<number>-<commits>-<short sha>`, e.g. `17.0.0-3-pr-12-004-a8aa8e0`
for the 4th commit of PR #12 (see `mise run version:pr`). The zero-padded
commit count makes a PR's prereleases sort in order; each push is a new
version, so Home Assistant offers it as an update. It consists of:

- images tagged with that version,
- a `pr/<number>` branch holding just the Home Assistant repository with that
  version, and
- a GitHub prerelease explaining how to install it.

To test a PR in Home Assistant, add
`https://github.com/victor-vanherpt/ha-forgejo-app#pr/<number>` as a repository
and install **Forgejo (PR #n)** from it. Uninstall it and remove the repository
when done.

When the PR is merged or closed,
[`pr-cleanup.yaml`](../.github/workflows/pr-cleanup.yaml) deletes the
prerelease, the branch and the images.

## Nightly Forgejo updates

[`forgejo-update.yaml`](../.github/workflows/forgejo-update.yaml) runs every
night (and on demand from the Actions tab). It runs `mise run forgejo:pin` on
top of `main` and, when a newer stable Forgejo release exists, opens a PR from
the `forgejo-update` branch with the new version, checksums, app version and
changelog entry. If that PR is still open when `main` moves on, the next run
refreshes it, so its version keeps matching what a squash merge will produce.

Check the linked Forgejo release notes before merging: Forgejo sometimes
advises against upgrading to a release.

PRs created with the workflow's own token don't start other workflows, so CI
only runs on the update PR automatically when the `FORGEJO_UPDATE_TOKEN`
secret is set (see [Repository settings](repository-settings.md)). Without
it, close and reopen the PR to start CI.
