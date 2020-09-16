# frozen_string_literal: true

require 'uri'
require 'httparty'
require 'addressable/uri'
require 'url_regex'
require 'active_support/core_ext/array/wrap'

require_relative '../tapp_printer' if ENV['DEBUG']

##
#  Namespace Module to wrap self-written Network tools
module NetworkUtils
  # Additional time to add to Ruby timeout as a workound
  # for HTTParty timeout issue when with the same timeout Ruby fails earlier
  CODE_TIMEOUT_EXTRA = 3

  ##
  # Simple class to get URL info (validation/existance, headers, content-type)
  # Allows to get all this stuff without actually downloading huge files like
  # CSVs, images, videos, etc.
  #
  class UrlInfo
    # Initialise a UrlInfo for a particular URL
    #
    # @param [String] url the URL you want to get info about
    # @param [Integer] request_timeout Max time to wait for headers from the server (seconds)
    #
    def initialize(url, request_timeout = 10)
      @url = String.new(url.to_s).force_encoding('UTF-8')
      @request_timeout = request_timeout
    end

    # Check the Content-Type of the resource
    #
    # @param [String, Symbol, Array] type the prefix (before "/") or full Content-Type content
    # @return [Boolean] true if Content-Type matches something from the types list
    def is?(type)
      return false if type.to_s.empty?

      expected_types = Array.wrap(type).map(&:to_s)
      content_type && expected_types.select do |t|
        content_type.select { |ct| ct.start_with?(t) }
      end.any?
    end

    # Check offline URL validity
    #
    # @return [Boolean] true if the URL is valid from the point of view of the standard
    def valid?
      @url.match?(UrlRegex.get(mode: :validation))
    end

    # Check online URL validity (& format validity as well)
    #
    # @return [Boolean] true if the URL is valid from the point of view of the
    #                   standard & exists (has headers)
    def valid_online?
      valid? && headers
    end

    # A shortcut method to get the remote resource size
    #
    # @return [Integer] remote resource size (bytes), 0 if there's nothing
    def size
      headers&.fetch('content-length', 0).to_i
    end

    # A shortcut method to get the Content-Type of the remote resource
    #
    # @return [String] remote resource Content-Type Header content
    def content_type
      headers&.fetch('content-type', nil)
             &.split(/,\s/)
             &.map { |ct| ct.split(/;\s/).first }
    end

    # A method to get the remote resource HTTP headers
    # Caches the result and returns memoised version
    #
    # @return [Hash, nil] remote resource HTTP headers list or nil
    def headers
      return nil if @url.to_s.empty?
      return nil unless (encoded_url = encode(@url))

      Timeout.timeout(@request_timeout + CODE_TIMEOUT_EXTRA) do
        response = HTTParty.head(encoded_url, timeout: @request_timeout)
        raise response.response if response.response.is_a?(Net::HTTPServerError) ||
                                   response.response.is_a?(Net::HTTPClientError)

        @headers ||= response.headers
      end
    rescue SocketError, ThreadError, Errno::ENETUNREACH, Errno::ECONNREFUSED,
           Errno::EADDRNOTAVAIL, Timeout::Error, TypeError,
           Net::HTTPServerError, Net::HTTPClientError, Net::OpenTimeout
      nil
    end

    private

    def encode(url)
      Addressable::URI.encode(url)
    end
  end
end
