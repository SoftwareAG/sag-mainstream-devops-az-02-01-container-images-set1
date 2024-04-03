#!/bin/bash

# shellcheck source=/dev/null

echo "INFO : Getting service principal credentials..."
if [ ! -f "${ACRSPCREDENTIALS_SECUREFILEPATH}" ]; then
  echo "ERROR:Secure file path not present: ${ACRSPCREDENTIALS_SECUREFILEPATH}"
  exit 1
fi

chmod u+x "${ACRSPCREDENTIALS_SECUREFILEPATH}"
. "${ACRSPCREDENTIALS_SECUREFILEPATH}"

if [ -z ${AZ_ACR_SP_ID+x} ]; then
  echo "ERROR:Secure information has not been sourced correctly"
  exit 2
fi

echo "INFO :Logging in to repository ${MY_AZ_ACR_URL}"
buildah login -u "${AZ_ACR_SP_ID}" -p "${AZ_ACR_SP_SECRET}" "${MY_AZ_ACR_URL}" || exit 1

echo "INFO :Logging out"
buildah logout "${MY_AZ_ACR_URL}"

exit 101
