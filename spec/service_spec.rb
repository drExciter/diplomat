require 'spec_helper'
require 'json'
require 'base64'

describe Diplomat::Service do

  let(:faraday) { fake }

  context "services" do
    let(:key) { "toast" }
    let(:key_url) { "/v1/catalog/service/#{key}" }
    let(:key_url_with_alloptions) { "/v1/catalog/service/#{key}?wait=5m&index=3" }
    let(:key_url_with_indexoption) { "/v1/catalog/service/#{key}?index=5" }
    let(:key_url_with_waitoption) { "/v1/catalog/service/#{key}?wait=6s" }
    let(:body) {
      [
        {
          "Node"        => "foo",
          "Address"     => "10.1.10.12",
          "ServiceID"   => key,
          "ServiceName" => key,
          "ServiceTags" => nil,
          "ServicePort" => "70457"
        },
        {
          "Node"        => "bar",
          "Address"     => "10.1.10.13",
          "ServiceID"   => key,
          "ServiceName" => key,
          "ServiceTags" => nil,
          "ServicePort" => "70457"
        }
      ]
    }
    let(:headers) {
      {
        "x-consul-index"        => "8",
        "x-consul-knownleader"  => "true",
        "x-consul-lastcontact"  => "0"
      }
    }

    describe "GET" do
      it ":first" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url).and_return(OpenStruct.new({ body: json }))

        service = Diplomat::Service.new(faraday)

        expect(service.get("toast").Node).to eq("foo")
      end

      it ":all" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url).and_return(OpenStruct.new({ body: json }))

        service = Diplomat::Service.new(faraday)

        expect(service.get("toast", :all).size).to eq(2)
        expect(service.get("toast", :all)[0].Node).to eq("foo")
      end
    end

    describe "GET With Options" do
      it "empty headers" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url).and_return(OpenStruct.new({ body: json, headers: nil }))

        service = Diplomat::Service.new(faraday)

        meta = {}
        s = service.get("toast", :first, {}, meta)
        expect(s.Node).to eq("foo")
        expect(meta.length).to eq(0)
      end

      it "filled headers" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url).and_return(OpenStruct.new({ body: json, headers: headers }))

        service = Diplomat::Service.new(faraday)

        meta = {}
        s = service.get("toast", :first, {}, meta)
        expect(s.Node).to eq("foo")
        expect(meta[:index]).to eq("8")
        expect(meta[:knownleader]).to eq("true")
        expect(meta[:lastcontact]).to eq("0")
      end

      it "index option" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url_with_indexoption).and_return(OpenStruct.new({ body: json, headers: headers }))

        service = Diplomat::Service.new(faraday)

        options = { :index => "5" }
        s = service.get("toast", :first, options)
        expect(s.Node).to eq("foo")
      end

      it "wait option" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url_with_waitoption).and_return(OpenStruct.new({ body: json, headers: headers }))

        service = Diplomat::Service.new(faraday)

        options = { :wait => "6s" }
        s = service.get("toast", :first, options)
        expect(s.Node).to eq("foo")
      end

      it "both options" do
        json = JSON.generate(body)

        faraday.stub(:get).with(key_url_with_alloptions).and_return(OpenStruct.new({ body: json, headers: headers }))

        service = Diplomat::Service.new(faraday)

        options = { :wait => "5m", :index => "3" }
        s = service.get("toast", :first, options)
        expect(s.Node).to eq("foo")
      end
    end

  end

end
