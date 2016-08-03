require 'spec_helper'
describe SpreeEventMailer do
  describe 'Broker' do
    let(:broker) { SpreeEventMailer::Broker.new }
    let(:mailer) { Spree::TestMailer }

    after(:each) do
      # Do a cleanup after each test
      SpreeEventMailer::Broker.class_variable_set :@@mailers, {}
      ActionMailer::Base.deliveries = []
    end

    it 'should register new mailers' do
      expect { SpreeEventMailer::Broker.add_mailer(Array) }.to raise_error(ArgumentError)
      expect { SpreeEventMailer::Broker.add_mailer(mailer, '') }.to raise_error(ArgumentError)

      expect(SpreeEventMailer::Broker.add_mailer(mailer, %w(success))).to be_a(Array)

      expect(broker.find_mailers_by_namespace('fail').size).to eq(0)
      expect(broker.find_mailers_by_namespace('success').size).to eq(1)

      expect(SpreeEventMailer::Broker.add_mailer(mailer)).to be_a(Array)
      expect(broker.find_mailers_by_namespace('fail').size).to eq(1)
    end

    it 'should dispatch mail' do
      SpreeEventMailer::Broker.add_mailer(mailer)

      expect { broker.dispatch('success', 'test_named_email', {}) }.to raise_error(ArgumentError)

      broker.dispatch 'success', 'test_named_email', email: 'max.berends@cg.nl'
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'should dispatch event mail' do
      SpreeEventMailer::Broker.add_mailer(mailer, ['test'])

      broker.dispatch_event 'test.test_named_email', email: 'max.berends@cg.nl'
      broker.dispatch_event 'fail.test_named_email', email: 'max.berends@cg.nl'
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
end
