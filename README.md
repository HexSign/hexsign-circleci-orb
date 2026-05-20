<p align="center">
  <a href="https://hexsign.io">
    <img src="https://hexsign.io/logo.png" alt="HexSign" height="64" />
  </a>
</p>

<h1 align="center">hexsign-circleci-orb</h1>

<p align="center">
  CircleCI orb for <a href="https://hexsign.io">HexSign</a> — install the CLI and fetch Apple signing material from your pipelines.
</p>

<p align="center">
  <a href="https://circleci.com/developer/orbs/orb/hexsign/hexsign">CircleCI Developer Hub</a>
  &nbsp;·&nbsp;
  <a href="https://hexsign.io">hexsign.io</a>
  &nbsp;·&nbsp;
  <a href="LICENSE">MIT License</a>
</p>

---

## Use

```yaml
version: 2.1

orbs:
  hexsign: hexsign/hexsign@1.0.0

workflows:
  release:
    jobs:
      - hexsign/fetch:
          context: hexsign            # contains HEXSIGN_CLIENT_ID / _SECRET
          certificate_id: $HEXSIGN_CERT_ID
          profile_id:     $HEXSIGN_PROFILE_ID
          output_dir:     build/sign
      - archive:
          requires: [hexsign/fetch]
```

## Authentication

The CLI auto-detects machine mode when these env vars are present:

| Variable | Required | Description |
|---|---|---|
| `HEXSIGN_CLIENT_ID`     | yes | Service-credential client ID. |
| `HEXSIGN_CLIENT_SECRET` | yes | Service-credential client secret. |
| `HEXSIGN_CLIENT_SCOPES` | no  | Override default scopes. |

Create a [CircleCI context](https://circleci.com/docs/contexts/) (Project → Organization Settings → Contexts) named `hexsign` and add both variables. Attach it at the workflow level — never paste secrets directly into `.circleci/config.yml`.

## Commands

### `hexsign/install`

Downloads the CLI from GitHub Releases, verifies it against `checksums.txt`, and puts the binary on `$PATH`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `version`     | string  | `latest`        | Release tag (e.g. `v0.2.1`) or `latest`. |
| `install_dir` | string  | `/usr/local/bin`| Where to install the binary. Added to `$PATH` via `$BASH_ENV`. |
| `use_sudo`    | boolean | `true`          | Prefix install with `sudo` (needed on most macOS/cimg images). |

### `hexsign/certificates_download`

Downloads one certificate (`id`) or every cert of a type for a team (`type` + `team_id`).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `id`         | string | `""` | Single certificate UUID. Mutually exclusive with `type`. |
| `type`       | string | `""` | Apple cert type (e.g. `IOS_DISTRIBUTION`). Requires `team_id`. |
| `team_id`    | string | `""` | Apple Developer team ID. |
| `output_dir` | string | `build/sign` | Directory for `.p12` and `.password` files. |

No-op when both `id` and `type` are empty.

### `hexsign/profiles_download`

Downloads one profile (`id`) or every profile for a bundle (`bundle_id`).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `id`         | string | `""` | Single profile UUID. Mutually exclusive with `bundle_id`. |
| `bundle_id`  | string | `""` | App bundle identifier. |
| `team_id`    | string | `""` | Optional, disambiguates across linked Apple accounts. |
| `output_dir` | string | `build/sign` | Directory for `.mobileprovision` files. |

No-op when both `id` and `bundle_id` are empty.

## Jobs

### `hexsign/fetch`

One-shot job that runs `install` + `certificates_download` + `profiles_download`, then `persist_to_workspace`s the output directory so downstream jobs can attach it.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `cli_version`       | string | `latest` | CLI release tag. |
| `certificate_id`    | string | `""` | Single cert UUID. |
| `certificate_type`  | string | `""` | Apple cert type for bulk download. Requires `team_id`. |
| `profile_id`        | string | `""` | Single profile UUID. |
| `bundle_id`         | string | `""` | Bundle id for bulk profile download. |
| `team_id`           | string | `""` | Apple Developer team id. |
| `output_dir`        | string | `build/sign` | Output directory. |
| `workspace_root`    | string | `.`      | Root passed to `persist_to_workspace`. |

At least one of `certificate_id`, `certificate_type`, `profile_id`, or `bundle_id` must be set.

## Composing into an existing macOS job

If you'd rather keep everything in one job (no workspace round-trip):

```yaml
jobs:
  archive:
    macos:
      xcode: 16.4.0
    steps:
      - checkout
      - hexsign/install
      - hexsign/certificates_download:
          id: $HEXSIGN_CERT_ID
          output_dir: build/sign
      - hexsign/profiles_download:
          id: $HEXSIGN_PROFILE_ID
          output_dir: build/sign
      - run: xcodebuild …
workflows:
  release:
    jobs:
      - archive:
          context: hexsign
```

## Bulk mode (rotation-safe)

```yaml
- hexsign/fetch:
    context: hexsign
    certificate_type: IOS_DISTRIBUTION
    team_id:          ABCDE12345
    bundle_id:        com.example.app
    output_dir:       build/sign
```

Downloads every distribution cert for the team and every profile attached to that bundle — no UUIDs to update when a cert or profile rotates.

## Development

The orb is authored as separate files under `src/`. Command logic lives in standalone shell scripts in `src/scripts/` and is imported into the YAML with the `<<include()>>` directive. `orb-tools/pack` flattens everything into a single `orb.yml` during CI.

```sh
# Lint and pack locally
circleci orb pack src/ > orb.yml
circleci orb validate orb.yml
```

Parameters and component names are `snake_case`, per the CircleCI `orb-tools/review` conventions.

### Publishing

The pipeline in [`.circleci/config.yml`](.circleci/config.yml):

- publishes `hexsign/hexsign@dev:<branch>` on every push (for testing in real pipelines);
- publishes a production release `hexsign/hexsign@vX.Y.Z` when a matching tag is pushed.

One-time setup before the first release:

```sh
circleci namespace create hexsign github hexsign
circleci orb create hexsign/hexsign
```

Set a `CIRCLE_TOKEN` env var inside the CircleCI context `orb-publishing` with orb publish scope.

## Contributing & security

- Bugs / feature requests: open a GitHub issue.
- Security vulnerabilities: email **support@hexsign.io** — please do **not** open a public issue.

## License

[MIT](LICENSE).
