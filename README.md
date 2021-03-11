# gskbuild

A Docker container for building an installable zip of [Site Kit by Google](https://github.com/google/site-kit-wp/)

## Basic Usage

```
$ docker run --rm -it -v "$PWD:/tmp/artifacts" aaemnnosttv/gskbuild
```

This builds the latest version of the plugin from the `develop` branch and copies the zip file into the current directory on the host machine.

**Building a Specific Branch**

To build from a branch other than the default, the branch name can be set using the `BRANCH` environment variable:

```
$ docker run --rm -it -v "$PWD:/tmp/artifacts" -e BRANCH=master aaemnnosttv/gskbuild
```

This builds the latest version of the plugin from the `master` branch and copies the zip file into the current directory on the host machine.

**Performing an Alternate Build**

By default, a release zip is built but the npm script invoked for the build can be changed by setting the `BUILD_SCRIPT` environment variable:

```
$ docker run --rm -it -v "$PWD:/tmp/artifacts" -e BUILD_SCRIPT=dev-zip aaemnnosttv/gskbuild
```

This would produce a development build of the zip file instead of the default production build.

## Advanced Usage

### Speeding Up the Build

By default, the repository source and all dependencies are downloaded and installed on every run. This can be a bit more performant by sharing local cache from the host machine.

```diff
  $ docker run --rm -it -v "$PWD:/tmp/artifacts" \
+   -v "$(composer global config cache-dir):/home/worker/.composer/cache" \
+   -v "$HOME/.npm:/home/worker/.npm" \
+   -v "$HOME/.nvm/versions:/home/worker/.nvm/versions" \
    aaemnnosttv/gskbuild
```

### Using Local Source

To build a branch that only exists locally, or to save time cloning via HTTP, the repository source can be mounted into the container instead:

```diff
  $ docker run --rm -it -v "$PWD:/tmp/artifacts" \
+   -v "local/path/to/repo:/app" \
+   -e REPO_SRC=file:///app \
    aaemnnosttv/gskbuild
```

The build will clone the repo internally using the current branch so only committed changes will be built.
