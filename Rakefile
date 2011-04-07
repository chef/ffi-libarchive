
begin
    require 'bones'
rescue LoadError
    abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
    name       'ffi-libarchive-ruby'
    authors    'Frank Fischer'
    email      'frank.fischer@mathematik.tu-chemnitz.de'
    url        'http://patch-tag.com/r/lyro/ffi-libarchive-ruby/wiki'
    depend_on  'ffi', '~> 1.0.0'
}

