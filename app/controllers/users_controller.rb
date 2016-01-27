class UsersController < ApplicationController
  def index
    do_stuff
  end

  def ip
    render text: local_ip
  end

  def urls
    @ip = local_ip
    render 'urls.plain.erb', layout: false, content_type: 'text/plain'
  end

  def hey
    render json: {a: 1, b: 2}
  end

  # Generate a bunch of fake endpoints. These can reached like: http://127.0.0.1:8080/users/index1/id.
  # Used to add more metric diversity to reporting periods.
  (1..100).to_a.each do |i|
    send :define_method, "index#{i}" do
      do_stuff
    end
  end

  private

  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

  def do_stuff
    sleep 2 if rand(100000) <= 434 # 0.43%
    City::connection.execute "select pg_sleep(0.05)" # generate some i/o wait
    @users = User.limit(20).all
    render action: 'index'
  end
end
