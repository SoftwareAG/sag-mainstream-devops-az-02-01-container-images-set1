#!/bin/bash

# shellcheck source=/dev/null

. ./setEnv.sh
. "${SUIF_CACHE_HOME}/01.scripts/commonFunctions.sh"

logI "Containerizing MS according to product default approach"
cd "${SUIF_INSTALL_INSTALL_DIR}/IntegrationServer/docker" || exit 1
./is_container.sh createLeanDockerfile -Dfile.name=Dockerfile_IS

logI "Removing license key"
rm "${SUIF_INSTALL_INSTALL_DIR}/IntegrationServer/config/licenseKey.xml"
touch "${SUIF_INSTALL_INSTALL_DIR}/IntegrationServer/config/licenseKey.xml"

cd "${SUIF_INSTALL_INSTALL_DIR}" || exit 2

export JOB_CONTAINER_BASE_TAG="${MY_AZ_ACR_URL}/msr-1015-lean-original-recipe:Fixes_${SUIF_FIXES_DATE_TAG}"
export JOB_CONTAINER_MAIN_TAG="${JOB_CONTAINER_BASE_TAG}_BUILD_${JOB_DATETIME}"

echo "##vso[task.setvariable variable=JOB_CONTAINER_MAIN_TAG;]${JOB_CONTAINER_MAIN_TAG}"
echo "##vso[task.setvariable variable=JOB_CONTAINER_BASE_TAG;]${JOB_CONTAINER_BASE_TAG}"

logI "Building container"
buildah \
  --storage-opt mount_program=/usr/bin/fuse-overlayfs \
  --storage-opt ignore_chown_errors=true \
  bud -f ./Dockerfile_IS --format docker -t "${JOB_CONTAINER_MAIN_TAG}"

contResult=$?
if [ "${contResult}" -ne 0 ]; then
  logE "Containerization failed, code ${contResult}"
  exit 3
fi

logI "Canonical container image created successfully"