# Repository settings

One-time GitHub settings that [CI](ci.md) relies on.

- **Packages**: after the first publish, make the `ha-forgejo-app`,
  `aarch64-ha-forgejo-app` and `amd64-ha-forgejo-app` packages public
  (GitHub → Packages → Package settings), or Home Assistant can't pull them.
- **General → Pull requests**: allow **squash merging** only. A merge commit
  breaks the version, which counts commits on `main` (see
  [Development](development.md#versions)).
- **Actions → General → Actions permissions**:
  - **Allow victor-vanherpt, and select non-victor-vanherpt, actions and
    reusable workflows**, with **Allow actions created by GitHub** checked
    (`actions/checkout`; without it every workflow fails at startup) and this
    list, which includes the actions the Home Assistant builder uses
    internally:

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
  contributors**: **Require approval for all external contributors**. PRs run
  their own copy of the workflow, so this is what keeps a fork's PR (and any
  workflow change in it) from running, or reporting a fake **CI result**,
  until you have reviewed it.
- **Actions → General → Workflow permissions**: **Read repository contents and
  packages permissions**, so tokens are read-only unless a job asks for more
  (the jobs here request exactly what they need).
- **Secrets and variables → Actions → New repository secret**
  `FORGEJO_UPDATE_TOKEN`: a
  [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new)
  with access to only this repository and the **Contents** and **Pull
  requests** permissions set to read and write, and a short expiry. The nightly
  [Forgejo update](ci.md#nightly-forgejo-updates) needs it to push and open its
  PRs so that they start CI. Don't grant it the **Workflows** permission: that
  would let the token rewrite the pipeline.
- **Rules → Rulesets** for the default branch, set to **Active** with no bypass
  list: restrict deletions, block force pushes, require a pull request (squash
  only), and require the status check **CI result** with branches up to date
  before merging. The check can only be selected after it has run once. Without
  this, the token above could release directly by pushing to `main`.
