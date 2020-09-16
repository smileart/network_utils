# frozen_string_literal: true

require 'active_support/all'
require 'network_utils/url_info'
require 'webmock/rspec'

require_relative './fixtures/url_info_fixtures'

RSpec.describe NetworkUtils::UrlInfo do
  let(:valid_urls) { UrlInfoFixtures::VALID_URLS }
  let(:invalid_urls) { UrlInfoFixtures::INVALID_URLS }
  let(:valid_https_url) { 'https://www.wikipedia.org' }
  let(:valid_http_url) { 'http://www.wikipedia.org' }
  let(:invalid_schema_url) { 'htt://www.wikipedia.org' }
  let(:invalid_domain_url) { 'https://www.wikipedia.or' }
  let(:not_encoded_url) { 'https://github.com/search?utf8=✓&q=test&type=' }
  let(:not_url) { 'blah blah' }
  let(:media_url) { 'https://www.wikipedia.org/portal/wikipedia.org/assets/img/Wikipedia-logo-v2@2x.png' }
  let(:xml_url) { 'https://httpbin.org/xml' }
  let(:delay_1) { 'https://httpbin.org/delay/1' }
  let(:delay_15) { 'https://httpbin.org/delay/15' }

  let(:multi_content_types_url) do
    Addressable::URI.unencode('https://httpbin.org/response-headers?Server=httpbin&Content-Type=text%2Fplain%3B+charset%3DUTF-8')
  end

  let(:multi_content_types) { ['application/json', 'text/plain'] }
  let(:not_avail) { 'https://localhost:0000' }
  let(:conn_refused) { 'https://httpbin.org:3000' }
  let(:open_timeout) { 'https://192.168.92.16' }

  context 'Instance' do
    it 'returns headers', vcr: true do
      expect(NetworkUtils::UrlInfo.new(valid_https_url).headers).to include('content-type')
    end

    it 'returns remote document size', vcr: true do
      expect(NetworkUtils::UrlInfo.new(media_url).size).to be > 0
    end
  end

  context 'Validation' do
    it 'validates URL offline', vcr: true do
      expect(NetworkUtils::UrlInfo.new(valid_https_url).valid?).to be_truthy
      expect(NetworkUtils::UrlInfo.new(valid_http_url).valid?).to be_truthy

      valid_urls.each do |url|
        expect(NetworkUtils::UrlInfo.new(url).valid?).to be_truthy
      end

      # @WARNING: THIS CASE IS ACTUALLY FALSY!!!
      expect(NetworkUtils::UrlInfo.new(invalid_domain_url).valid?).to be_truthy

      expect(NetworkUtils::UrlInfo.new(invalid_schema_url).valid?).to be_falsy
      expect(NetworkUtils::UrlInfo.new(not_url).valid?).to be_falsy

      invalid_urls.each do |url|
        expect(NetworkUtils::UrlInfo.new(url).valid?).to be_falsy
      end
    end

    it 'validates URL online', vcr: true do
      expect(NetworkUtils::UrlInfo.new(valid_https_url).valid_online?).to be_truthy
      expect(NetworkUtils::UrlInfo.new(not_encoded_url).valid_online?).to be_truthy
    end

    it 'returns false on URL with invalid schema', vcr: true do
      expect(NetworkUtils::UrlInfo.new(invalid_schema_url).valid?).to be_falsy
    end

    it 'returns false for inexistent URL', vcr: true do
      expect(NetworkUtils::UrlInfo.new(invalid_domain_url).valid_online?).to be_falsy
    end

    it 'invalid content-types for inexistent URL', vcr: true do
      expect(NetworkUtils::UrlInfo.new(invalid_domain_url).is?('text/html')).to be_falsy
    end
  end

  context 'Type and Headers check' do
    it 'checks content-type provided as Symbol', vcr: true do
      expect(NetworkUtils::UrlInfo.new(valid_https_url).is?(:text)).to be_truthy
    end

    it 'checks full content-type provided as String', vcr: true do
      expect(NetworkUtils::UrlInfo.new(valid_https_url).is?('text/html')).to be_truthy
    end

    it 'checks content-type provided as Array', vcr: true do
      expect(NetworkUtils::UrlInfo.new(xml_url).is?([:text, 'text/html', 'application/xml', 'text/csv'])).to be_truthy
    end

    it 'returns false on empty types', vcr: true do
      expect(NetworkUtils::UrlInfo.new(xml_url).is?(nil)).to be_falsy
      expect(NetworkUtils::UrlInfo.new(xml_url).is?([])).to be_falsy
      expect(NetworkUtils::UrlInfo.new(xml_url).is?('')).to be_falsy
    end

    it 'works properly with multiple Content-Types', vcr: true do
      content_types = NetworkUtils::UrlInfo.new(multi_content_types_url).content_type

      expect(content_types).to be_an(Array)
      expect(content_types).to eq(multi_content_types)
    end

    it 'checks media content-types + redirects', vcr: true do
      expect(NetworkUtils::UrlInfo.new(media_url).is?(:image)).to be_truthy
    end

    it 'returns nil from #headers on bad URI', vcr: true do
      url_info = NetworkUtils::UrlInfo.new(nil)

      expect(url_info.headers).to be_nil
      expect(url_info.content_type).to be_nil
      expect(url_info.size).to eq(0)
    end

    it 'returns nil from #headers on refused connection', vcr: true do
      url_info = NetworkUtils::UrlInfo.new(conn_refused)

      expect(url_info.headers).to be_nil
      expect(url_info.content_type).to be_nil
      expect(url_info.size).to eq(0)
    end

    it 'returns nil from #headers on read timeout', vcr: false do
      stub_request(:any, delay_1)
        .to_return(:body => lambda { |request| sleep 1; "test" }, status: 200)

      stub_request(:any, delay_15)
        .to_return(:body => lambda { |request| sleep 15; "test" }, status: 200)

      expect(NetworkUtils::UrlInfo.new(delay_1).headers).not_to be_nil
      expect(NetworkUtils::UrlInfo.new(delay_15).headers).to be_nil
    end

    it 'returns nil from #headers on open timeout', vcr: true do
      url_info = NetworkUtils::UrlInfo.new(open_timeout)

      expect(url_info.headers).to be_nil
      expect(url_info.content_type).to be_nil
      expect(url_info.size).to eq(0)
    end

    it 'returns nil from #headers on "not available"', vcr: true do
      url_info = NetworkUtils::UrlInfo.new(not_avail)

      expect(url_info.headers).to be_nil
      expect(url_info.content_type).to be_nil
      expect(url_info.size).to eq(0)
    end
  end
end
