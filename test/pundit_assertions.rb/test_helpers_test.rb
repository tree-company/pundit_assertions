# frozen_string_literal: true

require 'test_helper'

module PunditAssertions
  # NOTE: We create some dummy models class and pundit policy, to work with in our tests
  # This avoid us having to install more dependencies - just to test some basic stuff
  User = Struct.new(:name)

  class Comment
    def initialize(hidden: false)
      @hidden = hidden
      self.class.collection.push(self)
    end

    def public? = !@hidden

    def self.collection
      @collection ||= []
    end
  end

  class MockPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      !user.nil?
    end

    def permitted_attributes
      %i[content] unless user.nil?
    end

    def permitted_attributes_for_create
      %i[content hidden] unless user.nil?
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        return [] if user.nil?

        scope.collection.filter(&:public?)
      end
    end
  end
end

class PunditAssertions::MockPolicyTest < Minitest::Test
  include PunditAssertions::TestHelpers

  def setup
    @user = PunditAssertions::User.new
    @comment = PunditAssertions::Comment.new
  end

  def test_assert_permitted
    assert_permitted @user, @comment, :index
    assert_not_permitted nil, @comment, :index
    refute_permitted nil, @comment, :index
  end

  def test_that_returns_bool_for_permitted
    assert_equal true, permitted?(@user, @comment, :index)
    assert_equal false, permitted?(nil, @comment, :index)
  end

  def test_assert_permitted_attributes
    assert_permitted_attributes @user, @comment
    assert_no_permitted_attributes nil, @comment
  end

  def test_assert_permitted_attributes_with_action
    assert_permitted_attributes @user, @comment, :create
    assert_no_permitted_attributes nil, @comment, :create
  end

  def test_assert_attribute_permitted
    assert_attributes_permitted @user, @comment, :content
    assert_attributes_permitted @user, @comment, %i[content hidden], :create
    assert_not_attributes_permitted @user, @comment, :user
  end

  def test_assert_scope
    assert_scope_includes @user, @comment
    assert_scope_not_includes @user, PunditAssertions::Comment.new(hidden: true)
    assert_scope_empty nil, [@comment]
  end
end
