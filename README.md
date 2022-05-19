The semver shell utility
========================

semver is a little tool to manipulate version bumping in a project that
follows the [semver 2.x][semver] specification. Its uses are:

  - bump version
  - compare versions
  - extract specific version part
  - identify most significant difference between two versions
  - validate version syntax

It can be combined with `git` pre-commit hooks to guarantee correct versioning.

[semver]: https://github.com/mojombo/semver

[![Unit Tests and Linters](https://github.com/fsaintjacques/semver-tool/actions/workflows/ci.yaml/badge.svg)](https://github.com/fsaintjacques/semver-tool/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/fsaintjacques/semver-tool)](https://github.com/fsaintjacques/semver-tool/releases/latest)
[![License](https://shields.io/badge/license-Apache%202-blue)](https://github.com/fsaintjacques/semver-tool/blob/master/LICENSE)

installation
-----

The semver tool can be downloaded from github and made executable with these commands:

```bash
# Download the script and save it to /usr/local/bin
wget -O /usr/local/bin/semver \
  https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver

# Make script executable
chmod +x /usr/local/bin/semver

# Prove it works
semver --version
# semver: 3.3.0
```

Most likely, you will want to insure that the directory containing `semver` is on your `PATH`.

See [installation alternatives](#installation-alternatives) below.

usage
-----

```
Usage:
  semver bump (major|minor|patch|release|prerel [<prerel>]|build <build>) <version>
  semver compare <version> <other_version>
  semver diff <version> <other_version>
  semver get (major|minor|patch|release|prerel|build) <version>
  semver validate <version>
  semver --help
  semver --version

Arguments:
  <version>  A version must match the following regular expression:
             "^[vV]?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(\.(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"
             In English:
             -- The version must match X.Y.Z[-PRERELEASE][+BUILD]
                where X, Y and Z are non-negative integers.
             -- PRERELEASE is a dot separated sequence of non-negative integers and/or
                identifiers composed of alphanumeric characters and hyphens (with
                at least one non-digit). Numeric identifiers must not have leading
                zeros. A hyphen ("-") introduces this optional part.
             -- BUILD is a dot separated sequence of identifiers composed of alphanumeric
                characters and hyphens. A plus ("+") introduces this optional part.

  <other_version>  See <version> definition.

  <prerel>  A string as defined by PRERELEASE above. Or, it can be a PRERELEASE
            prototype string (or empty) followed by a dot.

  <build>   A string as defined by BUILD above.

Options:
  -v, --version          Print the version of this tool.
  -h, --help             Print this help message.

Commands:
  bump      Bump by one of major, minor, patch; zeroing or removing
            subsequent parts. "bump prerel" sets the PRERELEASE part and
            removes any BUILD part. A trailing dot in the <prerel> argument
            introduces an incrementing numeric field which is added or
            bumped. If no <prerel> argument is provided, an incrementing numeric
            field is introduced/bumped. "bump build" sets the BUILD part.
            "bump release" removes any PRERELEASE or BUILD parts.
            The bumped version is written to stdout.

  compare   Compare <version> with <other_version>, output to stdout the
            following values: -1 if <other_version> is newer, 0 if equal, 1 if
            older. The BUILD part is not used in comparisons.

  diff      Compare <version> with <other_version>, output to stdout the
            difference between two versions by the release type (MAJOR, MINOR,
            PATCH, PRERELEASE, BUILD).

  get       Extract given part of <version>, where part is one of major, minor,
            patch, prerel, build, or release.

  validate  Validate if <version> follows the SEMVER pattern (see <version>
            definition). Print 'valid' to stdout if the version is valid, otherwise
            print 'invalid'.

See also:
  https://semver.org -- Semantic Versioning 2.0.0
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
    $ semver bump prerel rc.1 1.0.1
    1.0.1-rc.1
    $ semver bump prerel rc.. 1.2.0-beta2
    1.2.0-rc.1
    $ semver bump prerel 1.0.1-rc.1+build4423
    1.0.1-rc.2
    $ semver bump prerel beta. 1.1.0-beta2
    1.1.0-beta3
    $ semver bump build build.051 1.0.1-rc1.1.0
    1.0.1-rc1.1.0+build.051
    $ semver bump release v0.1.0-SNAPSHOT
    0.1.0

Comparing version for scripting

    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1
    -1
    $ semver compare v1.0.1-rc1.1.0+build.051 V1.0.1-rc1.1.0
    0
    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rc1.1.0+build.052
    0
    $ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rb1.1.0
    1
    $ semver compare 10.1.4-rc4 10.4.2-rc1
    -1
    $ semver compare 10.1.4-rc4 10.4.2-1234
    -1

Find most significant difference

    $ semver diff 1.0.1-rc1.1.0+build.051 1.0.1
    prerelease
    $ semver diff 10.1.4 10.1.4

    $ semver diff 10.1.4-rc4 10.4.2-rc1
    minor

Extract version part

    $ semver get patch 1.2.3
    3
    $ semver get minor 1.2.3
    2
    $ semver get major 1.2.3
    1
    $ semver get prerel 1.2.3-rc.4
    rc.4
    $ semver get prerel 1.2.3-alpha.4.5
    alpha.4.5
    $ semver get build 1.2.3-rc.4+build.567
    build.567
    $ semver get release 1.2.3-rc.4+build.567
    1.2.3
    $ semver get prerel 1.2.3+build.568

    $ semver get prerel 1.2.3-rc.4+build.569
    rc.4
    $ semver get prerel 1.2.3-rc-4+build.570
    rc-4

Validate

    $ semver validate 1.0.0
    valid
    $ semver validate 1
    invalid

installation alternatives
-------------------------

The manual installation of the semver tool is simple: just place a single file where you want it.
Sometimes,
however, alternative installation mechanisms might be desired. Two such methods are referenced below.

### asdf

`asdf` is a tool version manager.
See the [`asdf`](https://asdf-vm.com/) documentation explaining how to set up asdf, install plugins and tools, and how to set/select versions.

The [semver plugin](https://github.com/mathew-fleisch/asdf-semver) handles the installation of the semver-tool. The README file contains an example installation.

### bpkg

[`bpkg`](https://github.com/bpkg/bpkg) is a lightweight bash package manager.
It takes care of fetching the shell scripts, installing them appropriately,
setting the execution permission and more.

The semver tool can be installed by running:
```sh
bpkg install -g semver-tool
```

