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

logI "Pushing tag ${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG}"
buildah push "${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG}" || exit 2

logI "Pushing tag ${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG}"
buildah push "${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG}" || exit 5

if [[ "${BUILD_SOURCEBRANCHNAME}" == "main" ]]; then
  logI "Source branch is main, overwriting tag ${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG} too"
  logI "Tagging ${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG} to ${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}}"
  buildah tag "${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG}" "${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}" || exit 3

  logI "Pushing tag ${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}"
  buildah push "${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}" || exit 4
fi

logI "Logging out"
buildah logout "${MY_AZ_ACR_URL}"

logI "Push completed"
