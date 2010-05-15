module Zena
  module Use
    module ZafuSafeDefinitions
      class ParamsDictionary
        include RubyLess
        safe_method ['[]', Symbol] => {:class => String, :nil => true}
      end

      module ViewMethods
        include RubyLess
        safe_method [:params] => ParamsDictionary
        safe_method_for String, [:gsub, Regexp, String] => {:class => String, :pre_processor => true}
        safe_method_for String, :upcase => {:class => String, :pre_processor => true}
        safe_method_for Time, :year => {:class => Number, :pre_processor => true}
      end
    end
  end
end