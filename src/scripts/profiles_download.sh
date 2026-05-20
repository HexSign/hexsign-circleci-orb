#!/usr/bin/env bash
# Download one provisioning profile by ID, or every profile matching a
# bundle identifier (bulk mode). No-op when no id or bundle-id is supplied.
#
# Reads (set as `environment` by the calling orb command):
#   HEXSIGN_PARAM_ID          provisioning profile UUID
#   HEXSIGN_PARAM_BUNDLE_ID   bundle identifier for bulk download
#   HEXSIGN_PARAM_TEAM_ID     Apple Developer team ID (optional)
#   HEXSIGN_PARAM_OUTPUT_DIR  directory for .mobileprovision files
set -euo pipefail

profile_id="${HEXSIGN_PARAM_ID}"
bundle_id="${HEXSIGN_PARAM_BUNDLE_ID}"
team_id="${HEXSIGN_PARAM_TEAM_ID}"
output_dir="${HEXSIGN_PARAM_OUTPUT_DIR}"

if [ -z "${profile_id}" ] && [ -z "${bundle_id}" ]; then
  echo "No profile id or bundle_id passed; skipping."
  exit 0
fi
if [ -n "${profile_id}" ] && [ -n "${bundle_id}" ]; then
  echo "Pass either id or bundle_id, not both." >&2
  exit 1
fi

mkdir -p "${output_dir}"

if [ -n "${profile_id}" ]; then
  echo "Downloading provisioning profile ${profile_id}…"
  hexsign profiles download "${profile_id}" --output-dir "${output_dir}"
elif [ -n "${team_id}" ]; then
  echo "Downloading every profile for bundle ${bundle_id} (team ${team_id})…"
  hexsign profiles download \
    --bundle-id "${bundle_id}" --team-id "${team_id}" \
    --output-dir "${output_dir}"
else
  echo "Downloading every profile for bundle ${bundle_id}…"
  hexsign profiles download \
    --bundle-id "${bundle_id}" --output-dir "${output_dir}"
fi
