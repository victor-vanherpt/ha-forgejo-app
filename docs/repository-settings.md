# Repository settings

One-time GitHub settings that [CI](ci.md) relies on.

- **Packages**: after the first publish, make the `ha-forgejo-app`,
  `aarch64-ha-forgejo-app` and `amd64-ha-forgejo-app` packages public
  (GitHub → Packages → Package settings), or Home Assistant can't pull them.
- **Environments → New environment** `ci-approval`: add the people who may
  approve CI runs under **Required reviewers**. Without it, PRs that need
  approval fail at **Authorize**. (The `ci` environment is created
  automatically and needs no protection.)
- **General → Pull requests**: allow **squash merging** only. A merge commit
  breaks the version, which counts commits on `main` (see
  [Development](development.md#versions)).
- **Actions → General → Actions permissions**:
  - **Allow victor-vanherpt, and select non-victor-vanherpt, actions and
    reusable workflows**, with **Allow actions created by GitHub** checked
    (`actions/checkout`) and this list, which includes the actions the Home
    Assistant builder uses internally:

    ```text
    jdx/mise-action@*,
    frenck/action-addon-linter@*,
    home-assistant/*,
    docker/build-push-action@*,
    docker/login-action@*,
    docker/setup-buildx-action@*,
    sigstore/cosign-installer@*
    ```

  - **Require actions to be pinned to a full-length commit SHA**. The workflows
    pin every action as `owner/repo@<sha> # vX.Y.Z`; when updating one, replace
    both the SHA and the version comment.
- **Actions → General → Approval for running fork pull request workflows from
  contributors**: **Require approval for all external contributors**. A PR can
  switch its own copy of the workflow back to `pull_request`, which runs the
  PR's version; this keeps such runs from starting (or reporting a fake
  **CI result**) until you have reviewed the change.
- **Actions → General → Workflow permissions**: **Read repository contents and
  packages permissions**, so tokens are read-only unless a job asks for more
  (the jobs here request exactly what they need).
- **Rules → Rulesets** for `main`: require a pull request, require the status
  check **CI result**, and require branches to be up to date before merging.
  The check can only be selected after it has run once.
