# Bake Test External

A gem for executing external (downstream) tests.

[![Development Status](https://github.com/ioquatix/bake-test-external/workflows/Test/badge.svg)](https://github.com/ioquatix/bake-test-external/actions?workflow=Test)

## Usage

Add a file `config/external.yaml` to your project, and add entries like:

``` yaml
bake:
  url: https://github.com/ioquatix/bake.git
  command: bundle exec rspec
  # branch: optional-branch-name
```

``` bash
$ bake test:external
```

It will clone the listed repositories, inject your current gem into the fetched gemfile, and run the given command. This has the effect of running their test suite with your latest code. You can use this as part of your test suite to receive feedback that a downstream dependent codebase is okay or broken because of a change you've made.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.
