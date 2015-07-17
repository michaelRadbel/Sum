require 'socket'

def server(host='localhost', port=4000, concurrent=2)
  server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  sockaddr = Socket.pack_sockaddr_in(port, host)
  server_socket.bind(sockaddr)
  server_socket.listen(1)

  clients = {}
  loop do 
    read, _, error = IO.select([server_socket] + clients.keys, nil, clients.keys)

    unless read.empty?
      read.each do |socket|
        if socket == server_socket
          if (pair = accept(server_socket, clients.size < concurrent))
            clients[pair[0]] = pair[1]
          end
        else
          begin
            msg, client_addrinfo = socket.recvfrom_nonblock(1024)
          rescue IO::WaitReadable
            puts 'read waiting'
            next
          end
          if msg.size == 0
            puts "#{clients[socket].inspect} disconnected."
            socket.close
            clients.delete(socket)
          else
            puts "#{clients[socket].inspect} sent #{msg.size} bytes"
          end
        end
      end
    end

    error.each do |socket|
      puts socket
      puts "#{clients[socket].inspect} disconnected via error"
      socket.close
      clients.delete(socket)
    end
  end
end

def accept(server_socket, should_accept)
  begin
    client, client_addrinfo = server_socket.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
    return
  end

  if should_accept
    puts "#{client_addrinfo.inspect} connected"
    [client, client_addrinfo]
  else
    puts "#{client_addrinfo.inspect} rejected"
    client.puts "Too many connections. Try again later"
    client.close
    nil
  end
end

server()
