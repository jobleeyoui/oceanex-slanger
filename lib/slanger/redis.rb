# Redis class.
# Interface with Redis.

require "forwardable"
require "oj"

module Slanger
  module Redis
    extend Forwardable

    def_delegators :subscriber, :subscribe

    def regular_connection
      @regular_connection ||= new_connection
    end

    def publisher
      @publisher ||= new_connection
    end

    def send_command(method, *arg)
      regular_connection.send(method, *arg)
    end

    def hincrby(*arg)
      send_command :hincrby, *arg
    end

    def hset(*arg)
      send_command :hset, *arg
    end

    def hdel(*arg)
      send_command :hdel, *arg
    end

    def hgetall(*arg)
      send_command :hgetall, *arg
    end

    def publish(*arg)
      publish_event(:publish, *arg)
    end

    def publish_event(method, *args)
      publisher.send(method, *args)
    end

    def subscriber
      @subscriber ||= new_connection.pubsub.tap do |c|
        c.on(:message) do |channel, message|
          message = Oj.strict_load(message)
          c = Channel.from message["channel"]
          c.dispatch message, channel
        end
      end
    end

    def new_connection
      EM::Hiredis.connect Slanger::Config.redis_address
    end

    extend self
  end
end
