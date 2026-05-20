# Changelog

## [Unreleased]

### Added
- Initial scaffold.
- `hexsign/install` command: downloads and verifies the CLI from GitHub Releases.
- `hexsign/certificates_download` command: single or bulk cert download.
- `hexsign/profiles_download` command: single or bulk profile download.
- `hexsign/fetch` job: install + downloads + workspace persist in one job.
- Two examples: `fetch_and_build` (workspace handoff) and `install_only` (single-job).
- `.circleci/config.yml` lints, packs, dev-publishes per branch, and promotes to a production release on `vX.Y.Z` tags.

### Notes
- Command logic lives in standalone shell scripts under `src/scripts/`, imported via `<<include()>>`, and all parameters/components are `snake_case` to satisfy `orb-tools/review`.
