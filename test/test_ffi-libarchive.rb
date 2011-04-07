
Dir.chdir File.dirname(__FILE__)

$LOAD_PATH.unshift '../lib/', '.'

require 'test/unit'
require 'sets/ts_read'
require 'sets/ts_write'
