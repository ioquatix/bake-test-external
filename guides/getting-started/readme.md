# Getting Started

This guide will help you get started with `bake-test-external` and show you how to use it in your project.

## Installation

Add the gem to your project:

```bash
$ bundle add bake-test-external
```

## Core Concepts

`bake-test-external` is a gem for executing external (downstream) tests. It allows you to run the test suite of a dependent project to ensure that your changes haven't broken anything. This is particularly useful when you have a gem that is used by other projects.

`bake-test-external` will clone the configured repositories, inject your current gem into the fetched gemfile, and run the given command. This has the effect of running their test suite with your latest code. You can use this as part of your test suite to receive feedback that a downstream dependent codebase is okay or broken because of a change you've made.

## Usage

Add a file `config/external.yaml` to your project, and add entries like:

```yaml
sus:
  url: https://github.com/ioquatix/sus
  command: bundle exec bake test
```

To run the external tests:

```bash
$ bake test:external
```

### Custom Environment Variables

You can specify custom environment variables to be set when running the external tests:

```yaml
sus:
  url: https://github.com/ioquatix/sus
  command: bundle exec bake test
  env:
    RUBYOPT: -W0
```

### Custom Gemfile

You can specify a custom gemfile to be used when running the external tests:

```yaml
sus:
  url: https://github.com/ioquatix/sus
  command: bundle exec bake test
  gemfile: path/to/gemfile
```

### Custom Branch

You can specify a custom branch to be checked out when running the external tests:

```yaml
sus:
  url: https://github.com/ioquatix/sus
  command: bundle exec bake test
  branch: my-feature-branch
```
