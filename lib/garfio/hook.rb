
require 'garfio/git'

module Garfio
  class Hook
    include Utils
    include Git

    def initialize
      @linters = []
      @runners = []
    end

    def lint(cmd, pattern, desc = nil)
      @linters << lambda do |file|
        if File.fnmatch(pattern, file)
          print_info("running #{desc || cmd} over #{file}\n")
          run("#{cmd} #{file}")
        end
        false
      end
    end

    def run_if(pattern, &block)
      @runners << lambda do |file|
        p File.fnmatch(pattern, file)
        if File.fnmatch(pattern, file)
          instance_exec(file, &block)
          return true
        end
        false
      end
    end

    def exec(&block)
      instance_exec(&block) if block_given?
      changed_files.each do |file|
        @linters.each do |lint|
          instance_exec(file, &lint)
        end

        @runners.each do |runner|
          next if instance_exec(file, &runner)
        end
      end
    end
  end
end
