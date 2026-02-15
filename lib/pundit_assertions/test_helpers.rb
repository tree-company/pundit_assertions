# frozen_string_literal: true

require_relative 'deprecation'

module PunditAssertions
  ##
  # A set of assertions to use in minitest
  #
  # This module should be included in your test class to use these assertions
  module TestHelpers
    extend PunditAssertions::Deprecation

    ##
    # Assert whether a user is permitted to perform an action
    def assert_permitted(user, record, action)
      msg = "Expected #{user.inspect} to be permitted to #{action} #{record}"

      assert permitted?(user, record, action), msg
    end

    ##
    # Assert whether a user is not permitted to perform an action
    def assert_not_permitted(user, record, action)
      msg = "Expected #{user.inspect} to not be permitted to #{action} #{record}"

      refute permitted?(user, record, action), msg
    end

    alias refute_permitted assert_not_permitted

    ##
    # Return whether a user is permitted to perform an action
    def permitted?(user, record, action)
      policy_class.new(user, record).public_send(:"#{action}?")
    end

    ##
    # Assert whether a user will have any attributes permitted
    def assert_has_permitted_attributes(user, record, action = nil)
      permitted = permitted_attributes(user, record, action)
      for_action = action.nil? ? '' : " for #{action}"
      message = "Expected #{user.inspect} to have permitted attributes#{for_action}\n"

      refute_nil permitted, message
      refute_empty permitted, message
    end

    deprecate_method :assert_permitted_attributes, :assert_has_permitted_attributes

    ##
    # Assert whether a user will have no attributes permitted
    def assert_no_permitted_attributes(user, record, action = nil)
      permitted = permitted_attributes(user, record, action)
      for_action = action.nil? ? '' : " for #{action}"
      permitted_message = "Attributes #{permitted.inspect} were permitted\n"
      message = "Expected #{user.inspect} to not have permitted attributes#{for_action}\n#{permitted_message}"

      assert_nil permitted, message
    end

    alias refute_permitted_attributes assert_no_permitted_attributes

    ##
    # Assert whether a user will have at least the specified attributes permitted
    # You can specify a specific action
    def assert_attributes_permitted(user, record, attributes, action = nil)
      attributes = [attributes] unless attributes.is_a?(Array)
      permitted = permitted_attributes(user, record, action)
      permitted = [] if permitted.nil?
      for_action = action.nil? ? '' : " for #{action}"

      assert_empty attributes - permitted,
                   "Expected #{user.inspect} to have #{attributes} in permitted attributes#{for_action}"
    end

    ##
    # Assert whether a user will not have any the specified attributes permitted
    def assert_not_attributes_permitted(user, record, attributes, action = nil)
      attributes = [attributes] unless attributes.is_a?(Array)
      permitted = permitted_attributes(user, record, action)
      permitted = [] if permitted.nil?
      union = (attributes & permitted)
      for_action = action.nil? ? '' : " for #{action}"

      assert_empty union, "Expected #{user.inspect} to not have #{union} in permitted attributes#{for_action}"
    end

    alias refute_attributes_permitted assert_not_attributes_permitted

    ##
    # Return the permitted attributes
    def permitted_attributes(user, record, action = nil)
      policy = policy_class.new(user, record)
      method = :permitted_attributes
      if !action.nil? && policy.respond_to?(:"permitted_attributes_for_#{action}")
        method = :"permitted_attributes_for_#{action}"
      end

      policy.send(method)
    end

    ##
    # Assert whether a user will have the specified records in scope
    def assert_scope_includes(user, *records)
      records.flatten.each do |record|
        assert_includes scope(user, record.class), record,
                        "Expected #{record} to be included in the scope for #{user.inspect}"
      end
    end

    ##
    # Assert whether a user will not have the specified records in scope
    def assert_not_scope_includes(user, *records)
      records.flatten.each do |record|
        refute_includes scope(user, record.class), record,
                        "Expected #{record} to not be included in the scope for #{user.inspect}"
      end
    end

    alias refute_scope_includes assert_not_scope_includes

    ##
    # Assert whether the scope for a user is empty
    def assert_scope_empty(user, klass)
      assert_empty scope(user, klass), "Expected scope for #{user.inspect} to be empty"
    end

    ##
    # Return the scoped records for a user and a klass
    def scope(user, klass)
      result = scope_class.new(user, klass).resolve

      refute_nil result
      result
    end

    ##
    # Get the policy class based on the current test class
    # This assumes this method is called inside `ModelPolicyTest` to get `ModelPolicy`
    def policy_class
      Object.const_get(self.class.to_s.gsub('Test', ''))
    end

    ##
    # Get the policy scope class based on the current test class
    # This assumes this method is called inside `ModelPolicyTest` or `ModelPolicyTest::Scope` to get `ModelPolicy::Scope`
    def scope_class
      klass = self.class.to_s.gsub('Test', '')
      klass << '::Scope' unless klass.match?(/::Scope$/)
      Object.const_get(klass)
    end
  end
end
