$:.unshift File.expand_path('../../lib', __FILE__)

require 'garfio'
require 'fileutils'

FileUtils.mkdir_p('/tmp/dummy')

begin
  File.open('/tmp/dummy/dummy.rb', 'w') do |f|
    f << 'print "garfio rules"'
  end

  Dir.chdir('/tmp/dummy') do
    print 'init dummy repository\n'
    system('git init > /dev/null')
    system('git add . > /dev/null')
    print 'make first commit\n'
    system("git commit -m 'first commit' > /dev/null")
  end

  print 'Install pre-commit\n'
  FileUtils.cp(
    File.join(Dir.pwd, 'examples/pre-commit'),
    '/tmp/dummy/.git/hooks/pre-commit'
  )

  Dir.chdir('/tmp/dummy') do
    print 'Install change file\n'
    File.open('/tmp/dummy/dummy.rb', 'w+') do |f|
      f << 'print :('
    end

    print 'Attempt commit\n'
    system("git commit -am 'with pre-commit' > /dev/null")

    print 'File error\n'
    File.open('/tmp/dummy/dummy.rb', 'w+') do |f|
      f << 'print ":)"'
    end

    print 'commit successfully\n'
    system("git commit -am 'with pre-commit' > /dev/null")
  end
ensure
  FileUtils.rm_r('/tmp/dummy')
end
