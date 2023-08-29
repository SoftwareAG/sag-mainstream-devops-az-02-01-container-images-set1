#!/bin/bash

# shellcheck source=/dev/null

# run from the folder containing setEnv.sh
. ./setEnv.sh
. "${SUIF_CACHE_HOME}/01.scripts/commonFunctions.sh"
. "${SUIF_CACHE_HOME}/01.scripts/installation/setupFunctions.sh"

# This template requires the following variables on top of the setup ones:

# not really a secret, Admin password will be set at startup time
export SUIF_INSTALL_TIME_ADMIN_PASSWORD="manage01"
# license is required by installer, but we will not embed it in the image
export SUIF_SETUP_TEMPLATE_MSR_LICENSE_FILE="${MSRLICENSE_SECUREFILEPATH}"

if [ ! -f "${SUIF_SETUP_TEMPLATE_MSR_LICENSE_FILE}" ]; then
    logE "User must provide a valid MSR license file"
    exit 1
fi

logI "SUIF env before installation of MSR:"
env | grep SUIF_ | sort

logI "Creating the home installation folder"

sudo mkdir -p "${SUIF_INSTALL_INSTALL_DIR}"
sudo chmod a+w "${SUIF_INSTALL_INSTALL_DIR}"

logI "Installing MSR..."

applySetupTemplate "MSR/1015/lean"

installResult=$?

if [ "${installResult}" -ne 0 ]; then
  logE "Installation failed, code ${installResult}"
  exit 2
fi

logI "MSR installation successful"