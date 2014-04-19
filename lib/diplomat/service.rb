require 'base64'
require 'faraday'

module Diplomat
  class Service < Diplomat::RestClient

    def get key
      ret = @conn.get "/v1/catalog/service/#{key}"
      return OpenStruct.new JSON.parse(ret.body).first
    end

    def self.get *args
      Diplomat::Service.new.get *args
    end

  end
end