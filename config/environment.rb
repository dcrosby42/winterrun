$PROJECT_ROOT = File.expand_path(__FILE__ + "/../..")
$LOAD_PATH << $PROJECT_ROOT + "/lib"

require "autoreload"
AutoReload.verbose = true
AutoReload.path_prefix = $PROJECT_ROOT

require "gosu"
require "ostruct"
require "pry"
