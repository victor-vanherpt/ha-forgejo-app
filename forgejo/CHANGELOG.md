# Changelog

## 17.0.0-25

- The nightly Forgejo update now opens the pull request when an earlier run pushed the update branch but failed to open it, instead of reporting success
- Smoke tests run without permission to publish or sign images, and the update token is only available to the step that uses it

## 17.0.0-24

- Release notes list the published image digests, how to verify the images' cosign signature, and the upstream Forgejo checksums

## 17.0.0-23

- Initial release: Forgejo [17.0.0](https://codeberg.org/forgejo/forgejo/releases/tag/v17.0.0) for aarch64 and amd64
