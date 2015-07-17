#!/usr/bin/env ruby

require 'socket'

def client(connections, host='localhost', port=4000)
  pending_sockets = {}
  connected_sockets = {}
  connections.times do
    pair = build_connection(host, port)
    handle_connection(pending_sockets, connected_sockets, pair)
  end

  loop do
    if pending_sockets.empty?
      puts 'Nothing to do, goodbye!'
      break
    end

    _, write, _ = IO.select(nil, pending_sockets.keys, nil)
    write.each do |socket|
      if pending_sockets.include?(socket)
        handle_connection(pending_sockets, connected_sockets, [socket, pending_sockets[socket]])
      else
        puts 'unhandled'
      end
    end
  end
end

def build_connection(host, port)
  socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  [socket, Socket.sockaddr_in(port, host)]
end

def connect(socket, sockaddr)
  begin
    socket.connect_nonblock(sockaddr)
    puts 'Connected 1'
    true
  rescue Errno::EISCONN
    puts 'Connected 2'
    true
  rescue IO::WaitWritable
    puts 'Waiting'
    false
  rescue => e
    socket.close
    puts e.inspect
    nil
  end
end

def handle_connection(pending, connected, pair)
  socket, sockaddr = pair
  case connect(socket, sockaddr)
  when true
    connected[socket] = sockaddr
    pending.delete(socket)
  when false
    pending[socket] = sockaddr
  else
    pending.delete(socket) if pending.include?(socket)
  end
end

if ARGV.count < 1
  puts "Usage: client.rb CONNECTIONS"
  exit 1
end

client(ARGV[0].to_i)