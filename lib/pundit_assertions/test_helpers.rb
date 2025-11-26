# frozen_string_literal: true

module PunditAssertions
  ##
  # A set of assertions to use in minitest
  #
  # This module should be included in your test class to use these assertions
  module TestHelpers
    ##
    # Assert whether a user is permitted to perform an action
    def assert_permitted(user, record, action)
      msg = "User #{user.inspect} should be permitted to #{action} #{record}, but isn't permitted"

      assert permitted?(user, record, action), msg
    end

    ##
    # Assert whether a user is not permitted to perform an action
    def assert_not_permitted(user, record, action)
      msg = "User #{user.inspect} should NOT be permitted to #{action} #{record}, but is permitted"

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
    def assert_permitted_attributes(user, record, action = nil)
      refute_empty permitted_attributes(user, record, action)
    end

    ##
    # Assert whether a user will have no attributes permitted
    def assert_no_permitted_attributes(user, record, action = nil)
      assert_nil permitted_attributes(user, record, action)
    end

    ##
    # Assert whether a user will have all of the specified attributes permitted
    # You can specify a specific action
    def assert_attributes_permitted(user, record, attributes, action = nil)
      attributes = [attributes] unless attributes.is_a?(Array)
      permitted = permitted_attributes(user, record, action)
      permitted = [] if permitted.nil?

      assert_empty attributes - permitted
    end

    ##
    # Assert whether a user will not have any the specified attributes permitted
    def assert_not_attributes_permitted(user, record, attributes, action = nil)
      attributes = [attributes] unless attributes.is_a?(Array)
      permitted = permitted_attributes(user, record, action)
      permitted = [] if permitted.nil?

      assert_equal attributes.length, (attributes - permitted).length
    end

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
    # Return the scoped records for a user and a klass
    def scope(user, klass)
      result = scope_class.new(user, klass).resolve

      refute_nil result
      result
    end

    ##
    # Assert whether a user will have the specified records in scope
    def assert_scope_includes(user, *records)
      records.flatten.each do |record|
        assert_includes scope(user, record.class), record
      end
    end

    ##
    # Assert whether a user will not have the specified records in scope
    def assert_scope_not_includes(user, *records)
      records.flatten.each do |record|
        result = scope(user, record.class)

        assert result.nil? || !result.include?(record)
      end
    end

    alias refute_scope_includes assert_scope_not_includes

    ##
    # Assert whether the scope for a user is empty
    def assert_scope_empty(user, klass)
      assert_empty scope(user, klass)
    end

    # This assumes this test is happening inside ModelPolicyTest
    def policy_class
      Object.const_get(self.class.to_s.gsub('Test', ''))
    end

    # This assumes this test is happening inside ModelPolicyTest or ModelPolicyTest::Scope
    def scope_class
      klass = self.class.to_s.gsub('Test', '')
      klass << '::Scope' unless klass.match?(/::Scope$/)
      Object.const_get(klass)
    end
  end
end
