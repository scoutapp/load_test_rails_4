class FastController < ApplicationController
  # Generate a bunch of fake endpoints. These can reached like: http://127.0.0.1:8080/steel/index1/id.
  # Used to add more metric diversity to reporting periods.
  (1..100).to_a.each do |i|
    send :define_method, "index#{i}" do
      do_stuff
    end
  end

  def index
    do_stuff
  end

  private

  def do_stuff
    user = User.order("RANDOM()").first
    render text: "Hello #{user.name}!"
  end

  include ActionController::Instrumentation
end