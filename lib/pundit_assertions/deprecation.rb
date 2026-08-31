# frozen_string_literal: true

module PunditAssertions
  module Deprecation # :nodoc:
    ##
    # Mark a method as deprecated and replace with a new method
    def deprecate_method(old_name, new_name)
      define_method(old_name) do |*args, **kwargs|
        message = "#{old_name} is deprecated and will be removed in a future release. Use #{new_name} instead.\n"

        # If we are in rails, we deprecate using rails' builtins, otherwise we use ruby's Warning
        if defined?(ActiveSupport::Deprecation)
          ActiveSupport::Deprecation.warn(message)
        else
          Warning.warn message, category: :deprecated
        end
        send(new_name, *args, **kwargs)
      end
    end
  end
end
