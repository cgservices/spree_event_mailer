module SpreeEventMailer
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_event_mailer'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do
      ActiveSupport::Notifications.subscribe(/./) do |*args| # match all
        event_name, _start_time, _end_time, _id, payload = args

        broker = SpreeEventMailer::Broker.new
        broker.dispatch_event(event_name, payload)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
