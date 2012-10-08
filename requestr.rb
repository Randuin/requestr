require 'sinatra'
require 'redis'
require 'slim'
require 'awesome_print'
require 'json'

class Requestr < Sinatra::Application
  if ENV["REDISTOGO_URL"]
    uri = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    REDIS = Redis.new
  end

  get '/' do
    unless params['p'] == 'hihi'
      return 'unauthorized'
    else
      @requests = REDIS.lrange('requests', 0, 20)
      @requests.map!{ |x| JSON.parse x }
      slim :index
    end
  end

  get '/request' do
    process_request params, 'get'
  end

  post '/request' do
    process_request params, 'post'
  end

  put '/request' do
    process_request params, 'put'
  end

  patch '/request' do
    process_request params, 'patch'
  end

  delete '/request' do
    process_request params, 'delete'
  end

  options '/request' do
    process_request params, 'options'
  end

  def process_request params, verb
    request = { verb: verb, params: params, time: Time.now }
    REDIS.lpush 'requests', request.to_json
    "[OK]"
  end
end
