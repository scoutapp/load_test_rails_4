class UsersController < ApplicationController
  def index
    do_stuff
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

  def do_stuff
    sleep 2 if rand(100000) <= 434 # 0.43%
    @users = User.limit(20).all
    render action: 'index'
  end
end
