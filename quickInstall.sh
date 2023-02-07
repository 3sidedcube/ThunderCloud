#!/usr/bin/env bash

#
# Script: quickInstall.sh
# Usage: ./quickInstall.sh
#
# An install script for the framework.
# This script will install any dependencies required and perform any additional set up.
#

# Set defaults
set -o nounset -o errexit -o errtrace -o pipefail

# ============================== Constants ==============================

# Get directory path of this script
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

# ============================== Main ==============================

# Move to project directory
cd ${DIR}

# Installs Carthage dependencies.
carthage update --platform ios --use-xcframeworks

# Downloads AppThinner from the ThunderCloud repository.
curl -O "https://raw.githubusercontent.com/3sidedcube/ThunderCloud/master/ThunderCloud/AppThinner"

# Makes AppThinner executable.
chmod +x AppThinner
