# frozen_string_literal: true

require 'socket'
require 'timeout'

##
#  Namespace Module to wrap self-written Network tools
module NetworkUtils
  ##
  # Simple class to work with ports
  # Allows to get random port number, check availability, etc.
  #
  class Port
    # The max limit for port lookup retries
    PORT_LOOKUP_RETRY_LIMIT = 50

    # Internet Assigned Numbers Authority suggested range
    IANA_PORT_RANGE = (49_152..65_535).freeze

    # Checks if the port is available (free) on the host
    #
    # @example
    #    NetworkUtils::Port.available?(9292)
    #    NetworkUtils::Port.available?(80, 'google.com', 100)
    #    NetworkUtils::Port.free?(80, 'google.com', 100)
    #    NetworkUtils::Port.free?(80, 'google.com', 100)
    #
    # @param [Integer] port the port we want to check availability of
    # @param [String]  host the host we want to check on (default: 127.0.0.1)
    # @param [Timeout] timeout the time (seconds) we ready to wait (default: 1)
    #
    # @return [Boolean] result of the check (true — port is free to use, false — the port is occupied)
    def self.available?(port, host = '127.0.0.1', timeout = 1)
      return false unless port && host && timeout && timeout.positive?

      Timeout.timeout(timeout) do
        TCPSocket.new(host, port).close
        false
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      true
    rescue SocketError, Timeout::Error, Errno::EADDRNOTAVAIL
      false
    end

    # Checks if the port is opened (occupied / being listened) on the host
    #
    # @example
    #    NetworkUtils::Port.opened?(443, 'google.com')
    #    NetworkUtils::Port.opened?(80, 'google.com', 1)
    #    NetworkUtils::Port.occupied?(80, 'google.com', 1)
    #    NetworkUtils::Port.occupied?(80, 'google.com', 1)
    #
    # @note Just the opposite of `available?`
    #
    # @param [Integer] port the port we want to check availability of
    # @param [String] host the host we want to check on (default: 127.0.0.1)
    # @param [Timeout] timeout the time (seconds) we ready to wait (default: 1)
    #
    # @return [Boolean] result of the check (true — the port is being listened, false — the port is free)
    def self.opened?(port, host = '127.0.0.1', timeout = 1)
      !available?(port, host, timeout)
    end

    # Generates random port from IANA recommended range
    #
    # @note
    #    The Internet Assigned Numbers Authority (IANA) suggests the
    #    range 49152 to 65535 (215+214 to 216−1) for dynamic or private ports.
    #
    # @return [Boolean] port the port from the IANA suggested range
    def self.random
      rand(IANA_PORT_RANGE)
    end

    # Generates random port from IANA recommended range which is free on the localhost
    #
    # @note
    #    The Internet Assigned Numbers Authority (IANA) suggests the
    #    range 49152 to 65535 (215+214 to 216−1) for dynamic or private ports.
    #
    # @return [Boolean] port the port from the IANA suggested range which is also free on the current machine
    def self.random_free
      PORT_LOOKUP_RETRY_LIMIT.times do
        port = random
        return port if available?(port)
      end

      nil
    end

    # Add a few nice aliases
    class << self
      # opened? → occupied?
      alias occupied? opened?

      # available? → free?
      alias free? available?
    end
  end
end
