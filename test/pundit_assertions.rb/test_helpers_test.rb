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

    def self.reset!
      @collection = []
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

class PunditAssertions::MockPolicyTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  include PunditAssertions::TestHelpers

  def setup
    @user = PunditAssertions::User.new
    @comment = PunditAssertions::Comment.new
  end

  def teardown
    PunditAssertions::Comment.reset!
  end

  def test_assert_permitted
    assert_permitted @user, @comment, :index
    error = assert_raises Minitest::Assertion do
      assert_permitted nil, @comment, :index
    end

    assert_equal "Expected nil to be permitted to index #{@comment}", error.message
  end

  def test_assert_not_permitted
    assert_not_permitted nil, @comment, :index
    error = assert_raises Minitest::Assertion do
      assert_not_permitted @user, @comment, :index
    end
    assert_equal "Expected PunditAssertions::User to not be permitted to index #{@comment}", error.message
  end

  def test_refute_permitted
    refute_permitted nil, @comment, :index
    error = assert_raises Minitest::Assertion do
      refute_permitted @user, @comment, :index
    end
    assert_equal "Expected PunditAssertions::User to not be permitted to index #{@comment}", error.message
  end

  def test_permitted
    assert_equal true, permitted?(@user, @comment, :index)
    assert_equal false, permitted?(nil, @comment, :index)
  end

  def test_assert_has_permitted_attributes
    assert_has_permitted_attributes @user, @comment
    error = assert_raises Minitest::Assertion do
      assert_has_permitted_attributes nil, @comment
    end
    assert_includes error.message, 'Expected nil to have permitted attributes'
  end

  def test_assert_has_permitted_attributes_with_action
    assert_has_permitted_attributes @user, @comment, :create
    error = assert_raises Minitest::Assertion do
      assert_has_permitted_attributes nil, @comment, :create
    end
    assert_includes error.message, 'Expected nil to have permitted attributes for create'
  end

  def test_assert_no_permitted_attributes
    assert_no_permitted_attributes nil, @comment
    error = assert_raises Minitest::Assertion do
      assert_no_permitted_attributes @user, @comment
    end
    assert_includes error.message, 'Expected PunditAssertions::User to not have permitted attributes'
    assert_includes error.message, 'Attributes [:content] were permitted'
  end

  def test_assert_no_permitted_attributes_with_action
    assert_no_permitted_attributes nil, @comment, :create
    error = assert_raises Minitest::Assertion do
      assert_no_permitted_attributes @user, @comment, :create
    end
    assert_includes error.message, 'Expected PunditAssertions::User to not have permitted attributes for create'
    assert_includes error.message, 'Attributes [:content, :hidden] were permitted'
  end

  def test_refute_permitted_attributes
    refute_permitted_attributes nil, @comment
    error = assert_raises Minitest::Assertion do
      refute_permitted_attributes @user, @comment
    end
    assert_includes error.message, 'Expected PunditAssertions::User to not have permitted attributes'
    assert_includes error.message, 'Attributes [:content] were permitted'
  end

  def test_assert_attribute_permitted
    assert_attributes_permitted @user, @comment, :content
    error = assert_raises Minitest::Assertion do
      assert_attributes_permitted nil, @comment, :content
    end
    assert_includes error.message, 'Expected nil to have [:content] in permitted attributes'
  end

  def test_assert_attribute_permitted_with_action
    assert_attributes_permitted @user, @comment, %i[content hidden], :create
    error = assert_raises Minitest::Assertion do
      assert_attributes_permitted nil, @comment, :content, :create
    end
    assert_includes error.message, 'Expected nil to have [:content] in permitted attributes for create'
  end

  def test_assert_not_attributes_permitted
    assert_not_attributes_permitted @user, @comment, :hidden
    assert_not_attributes_permitted nil, @comment, :content
    error = assert_raises Minitest::Assertion do
      assert_not_attributes_permitted @user, @comment, %i[content user]
    end
    assert_includes error.message, 'Expected PunditAssertions::User to not have [:content] in permitted attributes'
  end

  def test_assert_not_attributes_permitted_with_action
    assert_not_attributes_permitted @user, @comment, :user, :create
    assert_not_attributes_permitted nil, @comment, :content, :create
    error = assert_raises Minitest::Assertion do
      assert_not_attributes_permitted @user, @comment, %i[content hidden user], :create
    end
    assert_includes error.message,
                    'Expected PunditAssertions::User to not have [:content, :hidden] in permitted attributes for create'
  end

  def test_refute_attributes_permitted
    refute_attributes_permitted @user, @comment, :hidden
    refute_attributes_permitted nil, @comment, :content
    error = assert_raises Minitest::Assertion do
      refute_attributes_permitted @user, @comment, :content
    end
    assert_includes error.message, 'Expected PunditAssertions::User to not have [:content] in permitted attributes'
  end

  def test_permitted_attributes
    assert_equal [:content], permitted_attributes(@user, @comment)
    assert_equal %i[content hidden], permitted_attributes(@user, @comment, :create)
    assert_nil permitted_attributes(nil, @comment)
    assert_nil permitted_attributes(nil, @comment, :create)
  end

  def test_scope
    assert_equal [@comment], scope(@user, PunditAssertions::Comment)
    assert_empty scope(nil, PunditAssertions::Comment)
  end

  def test_assert_scope_includes
    assert_scope_includes @user, @comment
    error = assert_raises Minitest::Assertion do
      assert_scope_includes nil, @comment
    end
    assert_includes error.message, "Expected #{@comment} to be included in the scope for nil"
  end

  def test_assert_not_scope_includes
    assert_not_scope_includes @user, PunditAssertions::Comment.new(hidden: true)
    error = assert_raises Minitest::Assertion do
      assert_not_scope_includes @user, @comment
    end
    assert_includes error.message, "Expected #{@comment} to not be included in the scope for PunditAssertions::User"
  end

  def test_refute_scope_includes
    refute_scope_includes @user, PunditAssertions::Comment.new(hidden: true)
    error = assert_raises Minitest::Assertion do
      refute_scope_includes @user, @comment
    end
    assert_includes error.message, "Expected #{@comment} to not be included in the scope for PunditAssertions::User"
  end

  def test_assert_scope_empty
    assert_scope_empty nil, PunditAssertions::Comment
    error = assert_raises Minitest::Assertion do
      assert_scope_empty @user, PunditAssertions::Comment
    end
    assert_includes error.message, 'Expected scope for PunditAssertions::User to be empty'
  end
end
