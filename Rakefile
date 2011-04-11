
begin
    require 'bones'
rescue LoadError
    abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
    name       'ffi-libarchive'
    authors    'Frank Fischer'
    email      'frank.fischer@mathematik.tu-chemnitz.de'
    url        'http://darcsden.com/lyro/ffi-libarchive'
    depend_on  'ffi', '~> 1.0.0'
}

