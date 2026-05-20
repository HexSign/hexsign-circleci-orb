#!/usr/bin/env bash
# Validate inputs for the `fetch` job before doing any work.
#
# Reads (set as `environment` by the calling job):
#   HEXSIGN_PARAM_CERTIFICATE_ID
#   HEXSIGN_PARAM_CERTIFICATE_TYPE
#   HEXSIGN_PARAM_PROFILE_ID
#   HEXSIGN_PARAM_BUNDLE_ID
# Plus HEXSIGN_CLIENT_ID / HEXSIGN_CLIENT_SECRET from the CircleCI context.
set -euo pipefail

if [ -z "${HEXSIGN_PARAM_CERTIFICATE_ID}" ] && [ -z "${HEXSIGN_PARAM_CERTIFICATE_TYPE}" ] \
   && [ -z "${HEXSIGN_PARAM_PROFILE_ID}" ] && [ -z "${HEXSIGN_PARAM_BUNDLE_ID}" ]; then
  echo "At least one of certificate_id, certificate_type, profile_id, or bundle_id must be set." >&2
  exit 1
fi

if [ -z "${HEXSIGN_CLIENT_ID:-}" ] || [ -z "${HEXSIGN_CLIENT_SECRET:-}" ]; then
  echo "HEXSIGN_CLIENT_ID and HEXSIGN_CLIENT_SECRET must be in the environment (use a CircleCI context)." >&2
  exit 1
fi

echo "Inputs valid."
