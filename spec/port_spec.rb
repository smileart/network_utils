# frozen_string_literal: true

require 'socket'

RSpec.describe NetworkUtils::Port do
  let(:localhost) { 'localhost' }
  let(:localhost_ip) { '127.0.0.1' }
  let(:wrong_host) { 'randomwronghostindeed.io' }
  let(:google) { 'google.com' }
  let(:free_port) { NetworkUtils::Port.random_free }

  context 'Static' do
    def start_server(port = nil)
      # Listen on the port to occupy it for the test purposes
      occupied_port = port || NetworkUtils::Port.random_free

      # Let the server Thread to abort
      Thread.abort_on_exception = true

      # Create a server thread (not to lock the test flow)
      server = Thread.new(occupied_port) do |op|
        tmp_socket = TCPServer.open(localhost_ip, op)

        # Wait for clients to connect
        s = tmp_socket.accept

        # Close the server after
        s.close
      end

      # Let the server to start
      sleep(1)

      yield(occupied_port)

      server.join
    end

    it 'generates random port', vcr: false do
      expect(NetworkUtils::Port.random).to satisfy('be within range') { |random_port|
        NetworkUtils::Port::IANA_PORT_RANGE.include? random_port
      }
    end

    it 'generates random available port', vcr: false do
      random_free_port = NetworkUtils::Port.random_free

      expect(random_free_port).to satisfy('be within range') { |port|
        NetworkUtils::Port::IANA_PORT_RANGE.include?(port)
      }

      expect(NetworkUtils::Port.available?(random_free_port, '127.0.0.1', 2)).to be_truthy
    end

    it 'fails on timeout', vcr: false do
      start_server do |occupied_port|
        expect(NetworkUtils::Port.available?(occupied_port, '127.0.0.1', 2)).to be_falsy
      end
    end

    it 'checks port availability / occupation', vcr: false do
      start_server do |occupied_port|
        expect(NetworkUtils::Port.available?(occupied_port, '127.0.0.1', 2)).to be_falsy
        expect(NetworkUtils::Port.opened?(occupied_port, '127.0.0.1', 2)).to be_truthy
        expect(NetworkUtils::Port.occupied?(occupied_port, '127.0.0.1', 2)).to be_truthy

        expect(NetworkUtils::Port.available?(free_port, '127.0.0.1', 2)).to be_truthy
      end
    end

    it 'returns nil from #random_free when retry limit exceeded' do
      start_server do |occupied_port|
        allow(NetworkUtils::Port).to receive(:random) { occupied_port }
        expect(NetworkUtils::Port.random_free).to be_nil
      end
    end

    it 'checks ports being listened on the remote hosts', vcr: true do
      expect(NetworkUtils::Port.opened?(80, google)).to be_truthy
      expect(NetworkUtils::Port.opened?(443, google)).to be_truthy
    end

    it 'reports unavailability on any other error', vcr: true do
      expect(NetworkUtils::Port.available?(80, google, 2)).to be_falsy
      expect(NetworkUtils::Port.available?(80, wrong_host, 2)).to be_falsy
    end

    it 'returns the info of the service assigned to the port' do
      service = NetworkUtils::Port.service(22).first

      expect(service[:name]).to eq('ssh')
      expect(service[:port]).to eq(22)
      expect([:udp, :tcp].include?(service[:protocol])).to be_truthy
      expect(service[:description]).to eq('SSH Remote Login Protocol')
    end

    it 'returns nil of there\'s no service assigned to the port' do
      service = NetworkUtils::Port.service(4242)

      expect(service).to eq([])
    end

    it 'returns assigned service name for the given port' do
      service = NetworkUtils::Port.name(22)

      expect(service).to eq(["ssh"])
    end

    it 'returns nil when services file does not exist' do
      # Modify services file path
      env_backup = ENV['SERVICES_FILE_PATH']
      ENV['SERVICES_FILE_PATH'] = '/etc/whatever'

      service = NetworkUtils::Port.service(8080)

      expect(service).to be_nil

      # Returning the original ENV value
      ENV['SERVICES_FILE_PATH'] = env_backup
    end
  end
end
