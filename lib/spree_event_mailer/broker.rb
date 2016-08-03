module SpreeEventMailer
  class Broker

    # ATTRIBUTES = [:mailers]
    # mattr_reader *ATTRIBUTES

    @@mailers = {}

    def dispatch(namespace, action, payload)
      action = action.underscore # no .underscore!
      find_mailers_by_namespace(namespace).each do |mailer|
        mailer.send(action, payload).deliver_later if mailer.method_defined? action
      end
    end

    def dispatch_event(event, payload)
      action, namespace = event.split('.').reverse
      dispatch(namespace, action, payload)
    end

    def find_mailers_by_namespace(namespace)
      found_mailers = []

      @@mailers.each do |key, mailer_classes|
        found_mailers.concat(mailer_classes) if key.match namespace
      end

      found_mailers.uniq
    end

    def self.add_mailer(mailer, namespaces = [])
      raise ArgumentError, 'Mailer must be an mailer' unless mailer <= ActionMailer::Base
      raise ArgumentError, 'Namespaces must be an array' unless namespaces.is_a?(Array)

      namespaces << /.?/ if namespaces.empty? # Use the global namespace

      namespaces.each do |namespace|
        @@mailers[namespace] = [] if @@mailers[namespace].nil?
        @@mailers[namespace] << mailer
        @@mailers[namespace].uniq!
      end
    end

    def self.index
      @@mailers
    end
  end
end
