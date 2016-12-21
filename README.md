The semver shell utility
========================

semver is a little tool to manipulate version bumping in a project that
follows the [semver] specification. Its use are:

  - bump version
  - compare version

It can be combined `git` pre-commit hooks to guarantee a correct versioning.

[semver]: https://github.com/mojombo/semver
[gitflow]: https://github.com/nvie/gitflow

[![Build Status](https://travis-ci.org/fsaintjacques/semver-tool.svg?branch=master)](https://travis-ci.org/fsaintjacques/semver-tool)
[![Stable Version](https://img.shields.io/github/tag/fsaintjacques/semver-tool.svg)](https://github.com/fsaintjacques/semver-tool/tree/2.0.0)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg?style=flat)](https://github.com/fsaintjacques/semver-tool/blob/develop/LICENSE)


usage
-----

```
Usage:
  semver
  semver bump (major|minor|patch|prerel <prerel>|build <build>) <version>
  semver compare <version> <other_version>
  semver --help
  semver --version

Arguments:
  <version>  A version must match the following regex pattern:
             \"${SEMVER_REGEX}\".
             In english, the version must match X.Y.Z(-PRERELEASE)(+BUILD)
             where X, Y and Z are positive integers, PRERELEASE is an optionnal
             string composed of alphanumeric characters and hyphens and
             BUILD is also an optional string composed of alphanumeric
             characters and hyphens.

  <other_version>  See <version> definition.

  <prerel>  String that must be composed of alphanumeric characters and hyphens.

  <build>   String that must be composed of alphanumeric characters and hyphens.

Options:
  -v, --version          Print the version of this tool.
  -h, --help             Print this help message.

Commands:
  bump     Bump <version> by one of major, minor, patch, prerel, build
           or a forced potentialy conflicting version. The bumped version is
           shown to stdout.

  compare  Compare <version> with <other_version>, output to stdout the
           following values: -1 if <other_version> is newer, 0 if equal, 1 if
           older."
```

examples
--------

Basic bumping operations

    $ semver bump patch 0.1.0
    0.1.1
    $ semver bump minor 0.1.1
    0.2.0
    $ semver bump patch 0.2.0
    0.2.1
    $ semver bump major 0.2.1
    1.0.0
    $ semver bump patch 1.0.0
    1.0.1
    $ semver bump prerel rc1.1.0 1.0.1
    1.0.1-rc1.1.0
    $ semver bump build build.051 1.0.1-rc1.1.0
    1.0.1-rc1.1.0+build.051

Comparing version for scripting

    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1
    1
    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rc1.1.0
    0
    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rc1.1.0+build.052
    0
    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rb1.1.0
    1
    $ semver compare 10.1.4-rc4 10.4.2-rc1
    -1
