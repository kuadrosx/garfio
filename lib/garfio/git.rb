require 'garfio/utils'

module Garfio
  class Git
    include Utils

    def sync_with(dir, branch = nil)
      changed_files
      return false unless check_branch(branch)
      check_directory(dir)

      checkout_to(dir)
      true
    end

    def context
      @context ||= begin
        r = {}
        ENV.each do |var, value|
          next unless var.start_with? 'GIT_'
          r[var.gsub('GIT_', '').downcase] = value
        end
        r
      end
    end

    def pushed?(branch)
      @branches = []
      pushed = false
      STDIN.each do |line|
        (_, _, ref_name) = line.split
        ref_name = ref_name.split('/').last
        @branches << ref_name
        pushed ||= (branch == ref_name)
      end
      pushed
    end

    def checkout_to(dir)
      run("git --work-tree=#{dir} checkout -f")
    end

    def bare?
      run('git rev-parse --is-bare-repository', true).chomp == 'true'
    end

    private

    def check_directory(dir)
      unless File.exist? dir
        FileUtils.mkdir_p(dir)
        print_warn("sync_with: #{dir} did not exist, we created it for you")
      end

      return if ENV['GIT_INDEX_FILE'] &&
                File.exist?(File.join(dir, ENV['GIT_INDEX_FILE']))

      ENV['GIT_INDEX_FILE'] = nil
    end

    def check_branch(branch)
      return true if !branch || pushed?(branch)

      if @branches.empty?
        print_warn("sync_with: branch checking doesn't work in this hook")
      else
        print_error("sync_with: the branch #{branch} was not pushed")
        return false
      end
      true
    end
  end
end
