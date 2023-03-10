# Rebase Migrations

Rebase Migrations is a library and command line tool to rebase Rails migrations
to have the latest timestamp.

## Installation

```console
$ bundle add rails-rebase-migrations --group=development,test
```

## Scenario

Two team members, Alice and Bob, are working on the same Rails project and both
are adding new database migrations. Alice realizes her migration depends on
Bob's, but the migration timestamps are out of order. The `rebase-migration`
command line tool can be used to reorder Alice's new migrations to have the
latest timestamp in the sequence.

## Usage

To rebase all new migrations with respect to the `main` git branch:

```console
$ bundle exec rebase-migrations
```

To rebase all new migrations with respect to a different branch:

```console
$ bundle exec rebase-migrations my-branch
```

The command has a `--check` argument that is useful for CI. To check that all
new migrations are the latest in the sequence:

```console
$ bundle exec rebase-migrations --check
```

It will exit with status code 1 if the check fails. The `--check` form also
accepts a branch argument.

### Skipping Migrations

To skip a specific migration files from the `--check` include `_skip_rebase` in
its filename.
