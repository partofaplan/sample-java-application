#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EAR_PATH="${1:-${ROOT_DIR}/sample-ear/target/sample-ear.ear}"
ARCHIVE_ROOT="${ROOT_DIR}/weblogic/model"
WORK_DIR="${ARCHIVE_ROOT}/wdt-archive"
APPLICATIONS_DIR="${WORK_DIR}/wlsdeploy/applications"

if [[ ! -f "${EAR_PATH}" ]]; then
  echo "Expected EAR at ${EAR_PATH} but it was not found. Run 'mvn package' first." >&2
  exit 1
fi

rm -rf "${WORK_DIR}"
mkdir -p "${APPLICATIONS_DIR}"

cp "${EAR_PATH}" "${APPLICATIONS_DIR}/sample-ear.ear"

(cd "${WORK_DIR}" && zip -r "../archive.zip" wlsdeploy >/dev/null)

echo "WDT archive created at ${ARCHIVE_ROOT}/archive.zip"
