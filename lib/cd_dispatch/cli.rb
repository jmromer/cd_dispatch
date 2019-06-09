# frozen_string_literal: true

module CdDispatch
  class CLI < Thor
    LOG_FILE = "/tmp/cd_dispatch-sync.log"

    def initialize(*args, out: $stdout, **kwargs, &block)
      super(*args, **kwargs, &block)
      self.out = out
      self.logger = Logger.new(LOG_FILE, "daily", 5)
    end

    desc "list", "Print updated project listing"

    def list
      out.puts CDDispatch.project_listing
    end

    desc "sync", "Re-rank and update the project listing"

    def sync
      CDDispatch.save(CDDispatch.entries_updated)
      logger.info("Synced at #{Time.now}")
    end

    desc "save_entry", "Log the given path"

    def save_entry(path)
      return if ["~", "/", Dir.home].include?(path)

      CDDispatch.append([1, path, CDDispatch.build_label(path)])
    end

    desc "change_to", "Log a change to the given project, returning the path"

    def change_to(label)
      path = CDDispatch.parse_path(label)
      return if ["~", "/", Dir.home].include?(path)

      CDDispatch.append([1, path, label])

      out.puts path
    end

    desc "build_label", "Build a log entry label from the given file path"

    def build_label(entry)
      out.puts CDDispatch.build_label(entry)
    end

    desc "parse_path", "Parse the path from the given log entry"

    def parse_path(entry)
      out.puts CDDispatch.parse_path(entry)
    end

    private

    attr_accessor :logger, :out
  end
end
