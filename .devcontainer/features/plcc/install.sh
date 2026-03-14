#!/bin/bash
# Installs PLCC into /usr/local/lib/plcc.
# Runs as root during devcontainer image build.
set -euo pipefail

VERSION="${VERSION:-latest}"

apt-get update
apt-get install -y --no-install-recommends git
rm -rf /var/lib/apt/lists/*

if [ "$VERSION" = "latest" ]; then
    git clone --depth 1 --single-branch \
        https://github.com/ourPLCC/plcc /usr/local/lib/plcc
else
    git clone --depth 1 --single-branch --branch "$VERSION" \
        https://github.com/ourPLCC/plcc /usr/local/lib/plcc
fi

# Belt-and-suspenders: /etc/environment is sourced in all shell contexts,
# including non-login shells where containerEnv ${PATH} interpolation may not work.
# $PATH is intentionally expanded at install time (build-time root PATH).
echo 'PATH=/usr/local/lib/plcc/src/plcc/bin:'"$PATH" >> /etc/environment
