#!/bin/bash

set -euo pipefail

# Define the repository source.
## To use a local source, mount the repo to /app, prefixed with file://
## `-v "file://local/path/to/repo:/app"`
REPO_SRC=${REPO_SRC-https://github.com/google/site-kit-wp.git}

# Get the branch name to build.
## Set explicitly using `-e BRANCH=branch-name-to-build`
## Defaults to the current branch if mounted into the working directory,
## otherwise uses the default branch 'develop'.
if [ -z "${BRANCH-}" ]; then
    # Use branch of mounted source
    if [ -d "$PWD/.git" ]; then
        BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    else
        BRANCH="develop"
    fi
fi

echo "Building branch $BRANCH from $REPO_SRC"

# Clone the repo into an internal working directory.
## This ensures a clean working copy without altering the source if mounted from the host machine.
git clone --depth 1 "$REPO_SRC" --branch "$BRANCH" --single-branch "$HOME/working"

cd "$HOME/working"

# Install dependencies.

## Load nvm
source "$HOME/.nvm/nvm.sh" --no-use
## Install the required version of node according to .nvmrc.
nvm install

## Install node modules.
## Mount `-v "$HOME/.npm:/home/working/.npm"` to use package cache of host machine.
npm ci

## Install Composer packages.
## Mount `-v "$(composer global config cache-dir):/home/working/.composer/cache"` to use package cache from host machine.
composer install --no-dev --no-interaction --no-progress

# Build the distributable.
npm run "${BUILD_SCRIPT-release-zip}"

# Copy the generated zip file to the artifacts directory.
## Mount `-v "/local/output/dir:/tmp/artifacts"` to make artifacts available on the host machine.
cp ./*.zip "$ARTIFACTS_DIR"