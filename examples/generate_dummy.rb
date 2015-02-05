$:.unshift File.expand_path('../../lib', __FILE__)

require 'garfio'
require 'fileutils'

FileUtils.mkdir_p('/tmp/dummy')

begin
  File.open('/tmp/dummy/dummy.rb', 'w') do |f|
    f << 'print "garfio rules"'
  end

  Dir.chdir('/tmp/dummy') do
    print "init dummy repository\n"
    system('git init > /dev/null')
    system('git add . > /dev/null')
    print 'make first commit\n'
    system("git commit -m 'first commit' > /dev/null")
  end

  print "Install pre-commit\n"
  FileUtils.cp(
    File.join(Dir.pwd, 'examples/pre-commit'),
    '/tmp/dummy/.git/hooks/pre-commit'
  )

  FileUtils.cp(
    File.join(Dir.pwd, 'examples/post-commit'),
    '/tmp/dummy/.git/hooks/post-commit'
  )

  Dir.chdir('/tmp/dummy') do
    print "Install change file\n"
    File.open('/tmp/dummy/dummy.rb', 'w+') do |f|
      f << 'print :('
    end

    print "Attempt commit\n"
    system("git commit -am 'with pre-commit' > /dev/null")

    print "File error\n"
    File.open('/tmp/dummy/dummy.rb', 'w+') do |f|
      f << 'print ":)"'
    end

    print "commit successfully\n"
    system("git commit -am 'with pre-commit' > /dev/null")
  end

  FileUtils.mkdir_p('/tmp/dummy_bare')
  Dir.chdir('/tmp/dummy_bare') do
    system('git init --bare > /dev/null')
  end

  FileUtils.cp(
    File.join(Dir.pwd, 'examples/post-receive'),
    '/tmp/dummy_bare/hooks/post-receive'
  )

  FileUtils.chdir('/tmp/dummy') do
    system('git remote add deploy /tmp/dummy_bare > /dev/null')
    system('git push deploy master > /dev/null')

    system('git checkout -b copy > /dev/null')
    system('git push deploy copy > /dev/null')
  end
ensure
  FileUtils.rm_r('/tmp/dummy')
  FileUtils.rm_r('/tmp/dummy_copy')
  FileUtils.rm_r('/tmp/dummy_bare')
end
