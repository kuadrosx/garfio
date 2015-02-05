
require 'garfio/git'
require 'garfio/git/rugged'
require 'garfio/git/bash'

module Garfio
  class Hook
    include Utils

    attr_writer :working_dir
    attr_writer :working_branch

    def initialize
      @linters = []
      @runners = []
    end

    def lint(cmd, pattern, desc = nil)
      @linters << lambda do |file|
        if File.fnmatch(pattern, file)
          print_info("running #{desc || cmd} over #{file}")
          run("#{cmd} #{file}")
        end
        false
      end
    end

    def run_if(pattern, &block)
      @runners << lambda do |file|
        if File.fnmatch(pattern, file)
          instance_exec(file, &block)
          return true
        end
        false
      end
    end

    def exec(&block)
      return false if working_dir_required
      instance_exec(&block) if block_given?
      git.changed_files.each do |file|
        @linters.each do |lint|
          instance_exec(file, &lint)
        end

        @runners.each do |runner|
          next if instance_exec(file, &runner)
        end
      end
    end

    def git
      @git ||= begin
        if load_rugged
          Rugged.new
        else
          Bash.new
        end
      end
    end

    def load_rugged
      require 'rugged'
    rescue LoadError
      print "install rugged gem to improve performance\n"
    end

    private

    def working_dir_required
      if @working_dir
        return true unless git.sync_with(@working_dir, @working_branch)
        Dir.chdir(@working_dir)
      elsif git.bare?
        out = 'This is a repository bare,'
        out << 'You have to define a working directory'
        print_error(out)
        return true
      end
      false
    end
  end
end
