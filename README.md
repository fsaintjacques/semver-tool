The semver shell utility
========================

semver is a little tool to manipulate version bumping in a project that
follows the [semver] specification. Its use are:

  - bump version
  - compare version

It can be combined with [gitflow], and `git` pre-commit hooks to guarantee a
correct versioning for official releases (git flow release).

[semver]: https://github.com/mojombo/semver
[gitflow]: https://github.com/nvie/gitflow

[![Build Status](https://travis-ci.org/fsaintjacques/semver-tool.svg?branch=develop)](https://travis-ci.org/fsaintjacques/semver-tool)
[![Stable Version](https://img.shields.io/github/tag/fsaintjacques/semver-tool.svg)](https://github.com/fsaintjacques/semver-tool/tree/1.0.1)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg?style=flat)](https://github.com/fsaintjacques/semver-tool/blob/develop/LICENSE)


usage
-----

    Usage:
      semver
      semver init [<version>]
      semver bump [(major|minor|patch|prerel <prerel>|build <build>) | --force <version>] [--pretend]
      semver compare <version> [<oldversion>]
      semver release [--pretend]
      semver --help
      semver --version

    Arguments:
      <version>  A version must match the following regex pattern:
                 "^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$".
                 In english, the version must match X.Y.Z(-PRERELEASE)(+BUILD)
                 where X, Y and Z are positive integers, PRERELEASE is an optionnal
                 string composed of alphanumeric characters and hyphens and
                 BUILD is also an optional string composed of alphanumeric
                 characters and hyphens.

      <oldversion>  See <version> definition.

      <prerel>  String that must be composed of alphanumeric characters and hyphens.

      <build>   String that must be composed of alphanumeric characters and hyphens.

    Options:
      -f, --force=<version>  Forces a bump of any version without checking if it
                             respects semver bumping rules.
      -p, --pretend          Do not overwrite the project's version file, only
                             output what the new version string would be.
      -v, --version          Print the version of this tool.
      -h, --help             Print this help message.

    Commands:
      init     initialize this project's version.
      bump     this project's version by one of major, minor, patch, prerel, build
               or a forced potentialy conflicting version.
      compare  <version> to this project's version or to provided <oldversion>.
      release  release the current version.

examples
--------

Basic operations

    $ semver init
    0.1.0
    $ semver bump patch
    0.1.1
    $ semver bump minor
    0.2.0
    $ semver bump patch
    0.2.1
    $ semver bump major
    1.0.0
    $ semver bump patch
    1.0.1
    $ semver bump prerel rc1.1.0
    1.0.1-rc1.1.0
    $ semver bump build build.051
    1.0.1-rc1.1.0+build.051
    $ semver release -p
    1.0.1

Comparing version for scripting

    $ semver compare 1.0.1
    1
    $ semver compare 1.0.1-rc1.1.0
    0
    $ semver compare 1.0.1-rc1.1.0+build.052
    0
    $ semver compare 1.0.1-rb1.1.0
    -1
    $ semver compare 10.1.4-rc4 10.4.2-rc1
    -1

Advanced operations

    $ semver bump prerel rc2
    1.0.1-rc2
    $ semver bump --pretend major
    2.0.0
    $ semver
    1.0.1-rc2
    $ semver bump --force 2.0.0
    2.0.0
    $ semver bump -f 1.0.1-rc2
    1.0.1-rc2
    $ semver
    1.0.1-rc2
    $ semver bump -f 1.2.3-rc2+build -p
    1.2.3-rc2+build
    $ semver
    1.0.1-rc2
