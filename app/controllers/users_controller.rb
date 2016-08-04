class UsersController < ApplicationController
  def index
    do_stuff
  end

  # Generate a bunch of fake endpoints. These can reached like: http://127.0.0.1:8080/users/index1/id.
  # Used to add more metric diversity to reporting periods.
  (1..100).to_a.each do |i|
    send :define_method, "index#{i}" do
      do_stuff
    end
  end

  ### Benchmarking-utility actions...not actually hit during benchmarks ###

  def ip
    render text: local_ip
  end

  # Generate a file of URLs for load testing.
  def urls
    @ip = local_ip
    render 'urls.plain.erb', layout: false, content_type: 'text/plain'
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
    # used to add slow requests to an app and force a higher level of data collection in APM agent.
    if rand(100000) <= 434 # 0.43%
      fib(30) 
    else
      fib(8)
    end
    @users = User.limit(20).all
    render action: 'index'
  end

  def fib(n)
    case n
    when 0 then 1
    when 1 then 1
    else fib(n - 2) + fib(n - 1)
    end
  end
end
