require 'open3'
require 'pry'

module Garfio
  module Utils
    def run(cmd, silent = false)
      out = ''
      Open3.popen3(cmd) do |_, stdout, stderr, wait_thr|
        if wait_thr.value.success?
          out = stdout.read
          print_success(out) unless silent
        else
          print_error(stderr.read)
        end
      end
      out
    end

    def print_info(msg)
      print "\033[01;34m#{msg}\e[0m\n"
    end

    def print_success(msg)
      print "\e[1m\e[32m#{msg}\e[0m\n"
    end

    def print_error(msg)
      print "\e[1m\e[31m#{msg}\e[0m\n"
    end

    def print_warn(msg)
      print "\e[1m\e[33m#{msg}\e[0m\n"
    end
  end
end
