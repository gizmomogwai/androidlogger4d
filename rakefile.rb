desc 'format sources'
task :format do
  sh 'find . -name "*.d" | xargs dfmt -i'
end

task :default => [:format]
