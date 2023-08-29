#!/bin/bash
# shellcheck source=/dev/null

. ./setEnv.sh
. "${SUIF_CACHE_HOME}/01.scripts/commonFunctions.sh"

logI "Updating base libraries..."
sudo apt-get -y update
logI "OS Software updated (sometimes forked background processes remain nonetheless)"

logI "Installing prerequisites..."

maxRetries=5
crtRetry=0
lSuccess=1
while [ $lSuccess -ne 0 ]; do
  sudo apt-get install -y ca-certificates curl gnupg2 fuse-overlayfs
  lSuccess=$?
  if [ $lSuccess -eq 0 ]; then
    logI "Libraries installed successfully"
  else
    crtRetry=$((crtRetry+1))
    if [ $crtRetry -gt $maxRetries ]; then
      logE "Could not install the required libraries after the maximum number of retries!"
      exit 1
    fi
    logW "Installation of required libraries failed with code $lSuccess. Retrying $crtRetry/$maxRetries ..."
    sleep 10
  fi
done

. /etc/os-release
logI "Installing buildah for OS release ${VERSION_ID}..."
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -fsL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add - &&
sudo apt-get -qq -y update

crtRetry=0
lSuccess=1
while [ $lSuccess -ne 0 ]; do
  sudo apt-get -qq -y install buildah
  lSuccess=$?
  if [ $lSuccess -eq 0 ]; then
    logI "Buildah installed successfully"
  else
    crtRetry=$((crtRetry+1))
    if [ $crtRetry -gt $maxRetries ]; then
      logE "Could not install buildah after the maximum number of retries!"
      exit 1
    fi
    logW "Installation of buildah failed with code $lSuccess. Retrying $crtRetry/$maxRetries ..."
    sleep 10
  fi
done

if [ ! "$(buildah version)" ] ; then
  logE "Buildah is not available! Cannot continue"
  exit 3
fi


logI "Machine prepared"
