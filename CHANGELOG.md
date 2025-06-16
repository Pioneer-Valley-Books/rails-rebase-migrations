## 1.4.0 (2025-06-16)

Checkout previous version of `db/schema.rb` before re-applying migrations to
avoid conflicts.

## 1.3.0 (2024-11-13)

Add support for Rails 8.

## 1.2.0 (2024-03-14)

Always write out the new migration timestamp in UTC.

## 1.1.0 (2024-03-04)

Consider the timestamp of the latest migration as the initial value for rebased
migrations.

Improve user facing messages to be more explicit on use.

Remove the shebang from library files.

## 1.0.1 (2022-10-28)

Fix filename of Ruby lib to `rails_rebase_migrations.rb`.

## 1.0.0 (2022-10-28)

Initial release.
