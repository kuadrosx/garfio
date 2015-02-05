
module Garfio
  class Rugged < Git
    def changed_files
      @changed_files ||= begin
        ::Rugged::Repository.new(Dir.pwd).index.map { |f| f[:path] }
      end
    end
  end
end
