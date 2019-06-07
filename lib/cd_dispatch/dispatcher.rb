# frozen_string_literal: true

module CdDispatch
  module Dispatcher
    MAX_DEPTH = 4
    HISTORY_FILE = File.expand_path("~/.cd_dispatch.log")
    PROJECT_ROOTS = %w[
      ~/Desktop
      ~/Downloads
      ~/Dropbox
      ~/Projects
      ~/Work
    ].map { |path| File.expand_path(path) }

    # Return ["10,/path1/repo,repo (path1)", ...]
    def self.entries
      File
        .open(HISTORY_FILE, "r")
        .readlines
        .map! { |line| line.chomp.split(",") }
        .map! { |count, path, entry| [count.to_i, path, entry] }
    end

    # Sort entries in descending order of frequency.
    # Return [[["/path/dir", "dir (/path)"], 10], ...]
    def self.entries_by_frequency
      entries
        .each_with_object(Hash.new(0)) { |(count, path, entry), cts| cts[[path, entry]] += count }
        .sort_by { |_entry, count| -count }
    end

    # Remove any entries that no longer exist.
    def self.entries_pruned
      entries_by_frequency
        .select { |(path, _entry), _count| Dir.exist?(path) }
        .map! { |(path, _entry), count| [count, path, build_label(path)] }
    end

    # Search for and add any version-controlled projects not already in list.
    def self.new_projects
      PROJECT_ROOTS
        .flat_map { |root_dir| find_command(root_dir).split("\n") }
        .map! { |path| path.sub("/.git", "") }
        .to_set
        .difference(entries.map { |e| e[1] })
        .map! { |path| [1, path, build_label(path)] }
    end

    # Build and execute the command to recursively search for version-controlled
    # projects. Return the result (stdout contents) as a string.
    def self.find_command(root_dir)
      %x(/usr/local/bin/find \
         #{root_dir} \
         -regextype posix-extended \
         -maxdepth #{MAX_DEPTH} \
         -type d \
         -name .git)
    end

    # Return an array of paths - ranked entries followed by any newly found
    # projects at the end.
    def self.entries_updated
      [*entries_pruned, *new_projects]
    end

    def self.parse_path(log_entry)
      project_name, path = log_entry.uncolorize.split

      path = Dir.home if path.nil?
      path = "#{Dir.home}/#{path}" unless path.start_with?("/")

      "#{path}/#{project_name}"
    end

    def self.build_label(file_path)
      path = file_path.strip.sub(Dir.home, "~")
      root_segment, *segments, project_name = path.split("/")

      project_path =
        if root_segment == "~"
          segments.join("/")
        else
          [root_segment, *segments].join("/")
        end

      label = [project_name.colorize(:blue)]
      label << project_path.colorize(:light_black) unless project_path.empty?

      label.join(" ")
    end

    # Return ["project (~/dir/project)", "project2 (~/dir2/project2)", ...]
    def self.project_listing
      entries_updated.map! { |entry| entry[2] }
    end

    def self.save(list)
      text = list.map! { |entry| entry.join(",") }.join("\n")
      File.write(HISTORY_FILE, "#{text}\n", mode: "w")
    end

    def self.append(entry)
      text = entry.join(",")
      File.write(HISTORY_FILE, "#{text}\n", mode: "a")
    end
  end
end
