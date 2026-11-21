# Changelog

## 17.0.2-28

- Update Forgejo to [17.0.2](https://codeberg.org/forgejo/forgejo/releases/tag/v17.0.2)

## 17.0.0-27

- The nightly Forgejo update pushes its branch with the workflow's own short-lived token, and `FORGEJO_UPDATE_TOKEN` only opens the PR, so that token can no longer push or merge

## 17.0.0-26

- The nightly Forgejo update recreates its branch when `main` changed the workflows since the branch was pushed, instead of failing to push it

## 17.0.0-25

- The nightly Forgejo update now opens the pull request when an earlier run pushed the update branch but failed to open it, instead of reporting success
- Smoke tests run without permission to publish or sign images, and the update token is only available to the step that uses it

## 17.0.0-24

- Release notes list the published image digests, how to verify the images' cosign signature, and the upstream Forgejo checksums

## 17.0.0-23

- Initial release: Forgejo [17.0.0](https://codeberg.org/forgejo/forgejo/releases/tag/v17.0.0) for aarch64 and amd64
