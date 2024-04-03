#!/bin/bash

# shellcheck source=/dev/null

if [ ! -f "${SASECUREINFO_SECUREFILEPATH}" ]; then
  echo "ERROR: Secure file path not present: ${SASECUREINFO_SECUREFILEPATH}"
  exit 2
fi

echo "INFO : Sourcing secure information: Storage Account coordinates and credentials..."
chmod u+x "${SASECUREINFO_SECUREFILEPATH}"
. "${SASECUREINFO_SECUREFILEPATH}"

if [ -z ${SAG_AZ_SA_NAME+x} ]; then
  echo "ERROR: Secure information has not been sourced correctly: SAG_AZ_SA_NAME is missing!"
  exit 3
fi

if [ -z ${SAG_AZ_SA_KEY+x} ]; then
  echo "ERROR: Secure information has not been sourced correctly: SAG_AZ_SA_KEY is missing!"
  exit 6
fi

MOUNT_POINT="/tmp/testSA"

echo "Mounting the given file share"
mkdir -p "${MOUNT_POINT}"
sudo mount -t cifs "${SAG_AZ_SMB_PATH}" "${MOUNT_POINT}" -o "vers=3.0,username=${SAG_AZ_SA_NAME},password=${SAG_AZ_SA_KEY},dir_mode=0777,file_mode=0777"
resultMount=$?
if [ $resultMount -ne 0 ]; then
  echo "ERROR: Could not mount the images share, result ${resultMount}"
  echo "ERROR: Attempted to mount the SMB path ${SAG_AZ_SMB_PATH} using user ${SAG_AZ_SA_NAME}"
  exit 5
fi

sudo umount "${MOUNT_POINT}"
