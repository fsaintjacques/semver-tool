The semver shell utility
========================

semver is a little tool to manipulate version bumping in a project that
follows the [semver 2.x][semver] specification. Its uses are:

  - bump version
  - extract specific version part
  - compare versions
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
# semver: 3.4.0
```

Most likely, you will want to insure that the directory containing `semver` is on your `PATH`.

See [installation alternatives](#installation-alternatives) below.

usage
-----

```
Usage:
  semver bump major <version>
  semver bump minor <version>
  semver bump patch <version>
  semver bump prerel|prerelease [<prerel>] <version>
  semver bump build <build> <version>
  semver bump release <version>
  semver get major <version>
  semver get minor <version>
  semver get patch <version>
  semver get prerel|prerelease <version>
  semver get build <version>
  semver get release <version>
  semver compare <version> <other_version>
  semver diff <version> <other_version>
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
            prototype string followed by a dot.

  <build>   A string as defined by BUILD above.

Options:
  -v, --version          Print the version of this tool.
  -h, --help             Print this help message.

Commands:
  bump      Bump by one of major, minor, patch; zeroing or removing
            subsequent parts. "bump prerel" (or its synonym "bump prerelease")
            sets the PRERELEASE part and removes any BUILD part. A trailing dot
            in the <prerel> argument introduces an incrementing numeric field
            which is added or bumped. If no <prerel> argument is provided, an
            incrementing numeric field is introduced/bumped. "bump build" sets
            the BUILD part.  "bump release" removes any PRERELEASE or BUILD parts.
            The bumped version is written to stdout.

  get       Extract given part of <version>, where part is one of major, minor,
            patch, prerel (alternatively: prerelease), build, or release.

  compare   Compare <version> with <other_version>, output to stdout the
            following values: -1 if <other_version> is newer, 0 if equal, 1 if
            older. The BUILD part is not used in comparisons.

  diff      Compare <version> with <other_version>, output to stdout the
            difference between two versions by the release type (MAJOR, MINOR,
            PATCH, PRERELEASE, BUILD).

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
    $ semver bump prerelease rc.1 1.0.1
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
    $ semver get prerelease 1.2.3-rc.4
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

The [semver plugin](https://github.com/mathew-fleisch/asdf-semver) handles the installation of the semver-tool. The plugin README file contains an example installation.

### bpkg

[`bpkg`](https://github.com/bpkg/bpkg) is a lightweight bash package manager.
It takes care of fetching the shell scripts, installing them appropriately,
setting the execution permission and more.

The semver tool can be installed by running:
```sh
bpkg install -g semver-tool
```

### git

Clone this repo (or download a specific release). Then, `make install` will (by default--this can be changed) install `semver` in `/usr/local/bin`.

developing semver
-----------------

We welcome anyone wishing to contribute to `semver`.  Contributions can be new functionality, bug fixes, improvements to documentation, examples of usage (gists).

This is a small and rather simple tool: only one source file!  So, it's not too hard to get started.  A good starting place might be looking at the open issues.

Of course, submitting issues without being an active contributor is fine too.  Just be aware that issues that basically ask for someone to add something usually don't get much traction: it's always good to explain why it's a good idea,
how you would use it (i.e. your use-case), how other alternatives are not as good.

For a small project, there is a bit of rigor:

- Kick off a potential contribution by submitting an issue.  It should solicit comments.  Proposing a path forward is always good.  Issues are often an "intention to submit a pull request".
- Being a semantic versioning tool, we are sort of sensitive to breaking changes, compatibility.  Consistency is (almost) never a bad thing.
- Tests are expected.  We even test documentation.
- Commit messages should explain what was changed, why, design choices.
- Readable code--including comments, consistent formatting, reasonable names--along with good commit messages makes
reviewing work a pleasure.  It also means that new contributors can ramp up quickly and old folks can sleep,
wake up years later, and still catch up.
- We follow the usual Pull Request scheme. If you've submitted an issue (or commented on an existing one)
and gotten positive feedback on a proposed direction, then getting your PR accepted should be smooth.
Your PR should reference the issue(s) and indicate which issues it would close.
A PR out of the blue is generally a waste of everyone's time.

## the development environment

Once you have cloned the project, you have one main source file to work on: a bash script in `src/semver`.
Use your favorite editor or IDE.  The basic cycle is "hack-test-hack".
Of course, test driven developement works just fine here: write failing tests in `test` and then get them to pass.
Might as well: you will need to write that test sooner or later.

Oh, you might not be working on the `semver` script itself: you might be working on documentation (written in MarkDown) or the Makefile, or maybe the CI workflow (`yaml`).  But still, pretty simple stuff.

We use the [`bats`](https://github.com/bats-core/bats-core) testing framework.  It's pretty easy and still in `bash`.

We also use [`shellcheck`](https://github.com/koalaman/shellcheck) to "lint" our shell scripts. Your changes need to come through clean.

A custom test tool `test/documentation-test` makes sure that the examples in this REAME file are correct.

All the tests can be run via `make`.  This same Makefile is used for CI testing (GitHub Actions) when a PR is submitted.

### setting up test tools

One way to look at the testing environment is the following sequence of scenarios:

1. I use the test tools by hand on a specific change or test I'm working on.
So, I'll need to install these tools in my work environment.  Before starting work, I check that
the tools are set up correctly by running `make test-local`.  Everything should pass.

2. When my stuff works, and/or to make sure nothing else broke, I run `make test-local` The complete test suite
is identical to the test suite run automatically when I submit a pull request.  Except, except ... maybe
I did not install the version of the test tool used in CI.  I can check the tool version by looking
in the `DEPENDENCIES` file.  Of course, maybe it doesn't matter or maybe I'm exploring moving to
a different test tool version: I *want* the local version to differ from the "stable" version!

3. When I'm ready to submit a PR and so as to avoid the embarrasment of failing the CI workflow, I can run
`make test-stable`.  This runs the same tests as above, but uses currated Docker images of the test
tools: the same ones that the CI workflow will use.  Of course, I don't *have* to run this and it
requires that I have Docker installed, configured, and running.  On the other hand, once I have Docker
available, I don't strickly have to even install the test tools in my environment.  I can just
run the tests via Docker and/or via the Makefile. It's user choice.

4. When my pull request is sent, GitHub will kick off a workflow and `make test-stable` will be run.  If this
fails, it is most likely something about configuring the CI workflow or GitHub projects
(or `make` versions?) ... not because my code is failing the tests.  "It's not my fault!"

This can all be summarized as:

1. Test by hand.
2. Run the test suite locally.
3. Run the test suite using the stable environment.
4. Let GitHub Actions run the test suite using the stable environment.

### a note about dev environments

It is almost inescapable that developers have to understand and manage their environments, and this
can be a pain ... even for small projects.  And it is often a source of subtle errors.  If everything
was "auto-magic", "batteries included"; then who--if not the dev's--is going to do the work to
provide the batteries and magic?

But there are helpers available.  One of them mentioned above is [`asdf`](https://asdf-vm.com/).
Plugins for `bats` and `shellcheck` are available meaning that you can use `asdf` to set up your
`semver-tool` test environment as you wish: the current stable versions, exploratory versions, or
surely one day the next stable versions.
