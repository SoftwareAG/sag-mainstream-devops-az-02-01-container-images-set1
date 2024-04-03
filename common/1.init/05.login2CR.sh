#!/bin/bash

#shellcheck source=/dev/null

. ./setEnv.sh
. "${SUIF_CACHE_HOME}/01.scripts/commonFunctions.sh"

logI "Getting service principal credentials..."
if [ ! -f "${ACRSPCREDENTIALS_SECUREFILEPATH}" ]; then
  logE "Secure file path not present: ${ACRSPCREDENTIALS_SECUREFILEPATH}"
  exit 1
fi

chmod u+x "${ACRSPCREDENTIALS_SECUREFILEPATH}"
. "${ACRSPCREDENTIALS_SECUREFILEPATH}"

if [ -z ${AZ_ACR_SP_ID+x} ]; then
  logE "Secure information has not been sourced correctly"
  exit 2
fi

logI "Logging in to repository ${MY_AZ_ACR_URL}"
buildah login -u "${AZ_ACR_SP_ID}" -p "${AZ_ACR_SP_SECRET}" "${MY_AZ_ACR_URL}" || exit 1
