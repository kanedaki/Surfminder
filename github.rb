require 'goliath'
require 'nokogiri'
require 'em-synchrony/em-http'
require 'open-uri'
require 'tire'

module Indexmind

  
  class Indexmind::Doc
    include Tire::Model::Persistence

    def self.create_index
      @index = Tire::Index.new('entries')
      @index.delete
      @index.create
      @index.store :body => "Let's do it the old way!", :uri => "http://www.otra.com"
    end

    def self.store(url, page)
      @index.store :body => page.text.split(" "), :uri => url
      @index.refresh
    end

  end

  class Github < Goliath::API
    use Goliath::Rack::Params             # parse query & body params
    use Goliath::Rack::Formatters::JSON   # JSON output formatter
    use Goliath::Rack::Render             # auto-negotiate response format
    use Goliath::Rack::Validation::RequiredParam, {:key => 'url'}

    Doc.create_index

    def response(env)
      url = params['url']
      page = Nokogiri::HTML(open(url))
      # Filter which  tags you want to extract(h1, p....)
      index(url, page)
      [200, {}, page.class]
    end

    private
    def index(url, page)
      Indexmind::Doc.store(url, page)
    end
  end

end
