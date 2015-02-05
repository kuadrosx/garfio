
module Garfio
  class Bash < Git
    def changed_files
      @changed_files ||= begin
        data = run('git diff --cached --name-only --diff-filter=AM HEAD', true)
        data.split("\n").map(&:chomp)
      end
    end
  end
end
