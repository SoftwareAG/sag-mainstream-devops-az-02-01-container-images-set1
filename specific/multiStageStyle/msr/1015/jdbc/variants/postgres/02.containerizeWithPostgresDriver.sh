#!/bin/sh
# shellcheck source=/dev/null

# run from the folder containing setEnv.sh
. ./setEnv.sh
. "${SUIF_CACHE_HOME}/01.scripts/commonFunctions.sh"

logI "Preparing Postgres variant build context"

mkdir -p /tmp/msr-jdbc-pgsql-ctx || exit 1

# TODO: variabilize version
# TODO: ensure checksum checking
curl https://jdbc.postgresql.org/download/postgresql-42.7.3.jar -o /tmp/msr-jdbc-pgsql-ctx/postgresql-42.7.3.jar || exit 2

logI "driver downloaded from https://jdbc.postgresql.org/download/postgresql-42.7.3.jar"

export JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG="${MY_AZ_ACR_URL}/msr-1015-jdbc-custom-recipe1-pgsql:Fixes_${SUIF_FIXES_DATE_TAG}"
export JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG="${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}_BUILD_${JOB_DATETIME}"
export JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG="${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}_OCI_BUILD_${JOB_DATETIME}"

logI "Building Postgres variant container"
buildah \
  --storage-opt mount_program=/usr/bin/fuse-overlayfs \
  --storage-opt ignore_chown_errors=true \
  bud --format docker \
  --build-arg __from_img="${JOB_CONTAINER_MAIN_TAG}" \
  -t "${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG}" \
  -f ./specific/multiStageStyle/msr/1015/jdbc/variants/postgres/Dockerfile \
  /tmp/msr-jdbc-pgsql-ctx/ || exit 3

logI "Building Postgres variant container"
buildah \
  --storage-opt mount_program=/usr/bin/fuse-overlayfs \
  --storage-opt ignore_chown_errors=true \
  bud --format oci \
  --build-arg __from_img="${JOB_CONTAINER_MAIN_TAG}" \
  -t "${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG}" \
  -f ./specific/multiStageStyle/msr/1015/jdbc/variants/postgres/Dockerfile \
  /tmp/msr-jdbc-pgsql-ctx/ || exit 3

logI "Container ${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG} built successfully"

echo "##vso[task.setvariable variable=JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG;]${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_TAG}"
echo "##vso[task.setvariable variable=JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG;]${JOB_CONTAINER_POSTGRES_VARIANT_MAIN_OCI_TAG}"
echo "##vso[task.setvariable variable=JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG;]${JOB_CONTAINER_POSTGRES_VARIANT_BASE_TAG}"
echo "##vso[task.setvariable variable=JOB_CONTAINER_POSTGRES_VARIANT_PRODUCED;]true"
