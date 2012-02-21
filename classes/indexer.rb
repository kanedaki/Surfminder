require 'goliath'
require 'em-synchrony/em-http'

class Indexer < Goliath::API
  use Goliath::Rack::Params             # parse query & body params
  use Goliath::Rack::Formatters::JSON   # JSON output formatter
  use Goliath::Rack::Render             # auto-negotiate response format

  def response(env)
    gh = EM::HttpRequest.new("http://www.google.com").get
    [200, {'X-Goliath' => 'Proxy'}, gh.response]
  end
end
