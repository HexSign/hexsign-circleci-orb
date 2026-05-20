#!/usr/bin/env bash
# Download one signing certificate by ID, or every certificate of a given
# Apple cert type for one Apple Developer team (bulk mode). No-op when no
# id or type is supplied.
#
# Reads (set as `environment` by the calling orb command):
#   HEXSIGN_PARAM_ID          certificate UUID
#   HEXSIGN_PARAM_TYPE        Apple cert type for bulk download
#   HEXSIGN_PARAM_TEAM_ID     Apple Developer team ID
#   HEXSIGN_PARAM_OUTPUT_DIR  directory for .p12 / .password files
set -euo pipefail

cert_id="${HEXSIGN_PARAM_ID}"
cert_type="${HEXSIGN_PARAM_TYPE}"
team_id="${HEXSIGN_PARAM_TEAM_ID}"
output_dir="${HEXSIGN_PARAM_OUTPUT_DIR}"

if [ -z "${cert_id}" ] && [ -z "${cert_type}" ]; then
  echo "No certificate id or type passed; skipping."
  exit 0
fi
if [ -n "${cert_id}" ] && [ -n "${cert_type}" ]; then
  echo "Pass either id or type, not both." >&2
  exit 1
fi
if [ -n "${cert_type}" ] && [ -z "${team_id}" ]; then
  echo "certificate type requires team_id." >&2
  exit 1
fi

mkdir -p "${output_dir}"

if [ -n "${cert_id}" ]; then
  echo "Downloading certificate ${cert_id}…"
  hexsign certificates download "${cert_id}" --output-dir "${output_dir}"
else
  echo "Downloading every ${cert_type} certificate for team ${team_id}…"
  hexsign certificates download \
    --type "${cert_type}" --team-id "${team_id}" \
    --output-dir "${output_dir}"
fi
