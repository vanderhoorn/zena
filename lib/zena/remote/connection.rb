require 'HTTParty'

module Zena
  module Remote
    class Connection
      def initialize
      end

      # Return a sub-class of Zena::Remote::Connection with the specified connection tokens built in.
      def self.connect(uri, token)
        Class.new(self) do
          include HTTParty
          extend Zena::Remote::Interface::ConnectionMethods

          @found_classes = {}
          def self.[](class_name)
            @found_classes[class_name] ||= Zena::Remote::Klass.new(self, class_name)
          end

          def self.logger
            @logger ||= default_logger
          end

          def self.default_logger
            host = URI.parse(uri).host
            log_path = "log/#{host}.log"
            Dir.mkdir(log_path.dirname) unless File.exist?(log_path.dirname)
            Logger.new(File.open(log_path, 'ab'))
          end

          def self.logger=(logger)
            @logger = logger
          end

          headers 'Accept' => 'application/xml'
          headers 'HTTP_X_AUTHENTICATION_TOKEN' => token
          base_uri uri
        end
      end
    end
  end # Remote
end # Zena