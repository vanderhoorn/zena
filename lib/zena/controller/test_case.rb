module Zena
  module Controller
    class TestCase < ActionController::TestCase
      include Zena::Use::Fixtures
      include Zena::Use::TestHelper
      include Zena::Acts::Secure
      include ::Authlogic::TestCase

      def setup
        activate_authlogic
      end

      def login(fixture)
        super
        if defined?(@controller)
          @controller.class_eval do
            def set_visitor
              # do nothing
            end
          end
        end
      end

      def assert_match(match, target)
        return super if match.kind_of?(Regexp)
        target = Hpricot(target)
        assert !target.search(match).empty?,
          "expected tag, but no tag found matching #{match.inspect} in:\n#{target.inspect}"
      end

      def assert_no_match(match, target)
        return super if match.kind_of?(Regexp)
        target = Hpricot(target)
        assert target.search(match).empty?,
          "expected not tag, but tag found matching #{match.inspect} in:\n#{target.inspect}"
      end

      def err(obj)
        obj.errors.each_error do |er,msg|
          puts "[#{er}] #{msg}"
        end
      end
    end
  end
end