require './requestr'

use Rack::ShowExceptions

run Requestr.new
