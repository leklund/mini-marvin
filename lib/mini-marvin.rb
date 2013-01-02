require 'socket'
require 'openssl'

=begin

MiniMarvin - a very, very simple IRC notifier with a brain the size of a planet.

Example:

  MiniMarvin.loathing({:server => 'hostname',  :port => '6667', :password => 'password', :ssl => true, :nick => 'marv'}) do |paranoid_android|
   paranoid_android.notify("#heartofgold", "this will all end in tears")
  end

=end

class MiniMarvin

  def self.loathing(args, &block)
    bot = new(args)
    sleep 1
    yield bot
    bot.close
  end

  def initialize(args)
    password = args[:password] || nil
    ssl = args[:ssl] || false
    nick = args[:nick] || 'Marvin'
    self.connect(args[:server], args[:port], nick, password, ssl)
  end

  def connect(server, port, nick, password=nil, ssl=false)
    sock = TCPSocket.open(server, port || 6667)
    if ssl
      context = OpenSSL::SSL::SSLContext.new()
      context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      sock = OpenSSL::SSL::SSLSocket.new(sock, context)
      sock.sync_close = true
      sock.connect
    end
    @socket = sock
    @socket.puts "PASS #{password}" if password
    @socket.puts "NICK #{nick}"
    @socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
  end

  def close
    @socket.puts "QUIT"
    @socket.gets until @socket.eof?
  end

  def notify(channels, message)
    channels = [channels] unless channels.kind_of?(Array)
    channels.each do |chan|
      @socket.puts "NOTICE #{chan} :#{message}"
    end
  end
end
