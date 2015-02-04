require 'garfio/utils'

module Garfio
  include Utils
  module Git
    def changed_files
      @changed_files ||= begin
        if load_rugged
          Rugged::Repository.new(Dir.pwd).index.map { |f| f[:path] }
        else
          data = run('git diff --cached --name-only --diff-filter=AM HEAD', true)
          data.split("\n").map(&:chomp)
        end
      end
    end

    def sync_with(directory)
      unless File.exist? directory
        print_error("sync_with: #{directory} does not exists")
        return false
      end
      run("git --work-tree=#{directory} checkout -f")
      true
    end

    def load_rugged
      require 'rugged'
    rescue LoadError
      print "install rugged gem to improve performance\n"
    end
  end
end
