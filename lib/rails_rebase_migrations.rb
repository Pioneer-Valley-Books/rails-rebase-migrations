#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'optparse'
require 'shellwords'

class RebaseMigrations
  SKIP_REBASE = '_skip_rebase_'

  MIGRATIONS_DIR = 'db/migrate/'
  MIGRATION_NAME_RE = /^(\d+)(.*)$/

  def main
    ref, options = parse_args

    out = subprocess('git', 'ls-files', '--', MIGRATIONS_DIR)
    all_migrations = out.lines(chomp: true).to_a.sort

    out = subprocess('git', 'diff', '--diff-filter=A', '--name-only', ref, '--', MIGRATIONS_DIR)
    new_migrations = out.lines(chomp: true).to_a.sort

    starting_index = all_migrations.length - new_migrations.length

    now = Time.now.to_i

    return if new_migrations.empty?

    new_migrations.each do |path|
      basename = File.basename(path)
      match = MIGRATION_NAME_RE.match(File.basename(path))
      migration_timestamp = match[1]
      migration_name_base = match[2]
      next if migration_name_base.start_with?(SKIP_REBASE)

      if options[:check]
        index = all_migrations.index(path)
        if index < starting_index
          skip_migration_name = "#{migration_timestamp}#{SKIP_REBASE}#{migration_name_base[1..]}"

          warn <<~MSG
            Migration #{basename} is out of order. It should come after
            pre-existing migrations. To fix, run the command:

              $ ./tools/rebase-migrations

            If the migration is intentionally out of order, add the magic
            string "#{SKIP_REBASE}" to the beginning of the migration name:

              $ git mv #{path} #{MIGRATIONS_DIR}#{skip_migration_name}

            If this pull request is merging across branches prod, staging, or
            main, then add the "review-merge" label.
          MSG

          exit 1
        end
      else
        new_timestamp = Time.at(now).utc.strftime('%Y%m%d%H%M%S')
        new_migration_name = "#{new_timestamp}#{migration_name_base}"
        subprocess('git', 'mv', path, "#{MIGRATIONS_DIR}#{new_migration_name}")
        # Add 120s so the new migrations maintain the same order and provides
        # room between the migrations to inject new ones.
        now += 120
      end
    end

    return if options[:check]

    # Regenerate db/schema.rb
    system('rails', 'db:drop', 'db:create', 'db:migrate', exception: true)
    subprocess('git', 'add', 'db/schema.rb')
  end

  private

  def parse_args
    options = {}

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{opts.program_name} [--check] [REF]"

      opts.on('--check', 'Check new migrations are ordered last. Exit with status code 1 if they are not.')

      opts.on('--help', '-h', 'Print this help') do
        puts opts
        exit
      end
    end

    args = parser.parse(ARGV, into: options)
    if args.length > 1
      warn "Expected 0 or 1 positional arguments but found #{args.length}."
      exit 2
    end
    ref = args.first || 'main'

    [ref, options]
  end

  def subprocess(*args)
    stdin, stdout, wait_thr = Open3.popen2(*args)
    stdin.close
    out = stdout.read
    stdout.close
    status = wait_thr.value

    raise "Command failed: #{status}\n\n  #{Shellwords.join(args)}\n" if status != 0

    out
  end
end
