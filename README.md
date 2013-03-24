semver's utily
==============

semver is a little tool to manipulate version bumping in a project that
follows the [semver] specification. Its use are:

  - bump version
  - compare version

It can be combined with [gitflow], and git pre-commit hooks to garantee a
correct versioning for official releases (git flow release).

[semver]: https://github.com/mojombo/semver
[gitflow]: https://github.com/nvie/gitflow

usage
-----

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
    $ semver bump prerel rc1
    1.0.1-rc1
    $ semver bump meta build051
    1.0.1-rc1+build051

Comparing version for scripting

    $ semver compare 1.0.1
    -1
    $ semver compare 1.0.1-rc1
    0
    $ semver compare 1.0.1-rc1+build052
    0
    $ semver compare 1.0.1-rb1
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
    $ semver bump -f 1.2.3-rc2+meta -p
    1.2.3-rc2+meta
    $ semver
    1.0.1-rc2
