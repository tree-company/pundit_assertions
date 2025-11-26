# PunditAssertions

A simple gem to make testing [Pundit](https://github.com/varvet/pundit) policies easier. This provides a set of assertions

We deduce the relevant based on the name of the test class: We assume that `CommentPolicy` gets tested in `CommentPolicyTest`, `Admin::CommentPolicy` in `Admin::CommentPolicyTest`, ...

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

You can include the test helpers in all tests, or include this in a specific file:
```ruby
require 'pundit_assertions'

module ActiveSupport
  class TestCase
    include PunditAssertions::TestHelpers
  end
end
```

```ruby
require 'pundit_assertions'

class CommentPolicyTest < ActiveSupport::TestCase
  include PunditAssertions::TestHelpers
end
```

## Usage
We provide a bunch of custom assertions to help you validate your policies:
```ruby
class CommentPolicyTest < ActiveSupport::TestCase
  setup do
    @user = User.new
    @comment = Comment.new
  end

  test 'should only allow index for user' do
    assert_permitted @user, @comment, :index
    assert_not_permitted nil, @comment, :index
  end

  test 'should allow permitted attributes for user' do
    assert_permitted_attributes @user, @comment
    assert_no_permitted_attributes nil, @comment
  end

  test 'should only allow private attribute on create' do
    assert_attribute_permitted @user, @comment, :private, :create
    assert_not_attribute_permitted @user, @comment, :private, :update
  end

  test 'should scope comments that belong to user' do
    users_comment = Comment.create!(user: @user)
    other_comment = Comment.create!(user: User.new)

    assert_scope_includes @user, users_comment
    assert_scope_not_includes @user, other_comment
    assert_scope_empty @user, Comment
  end 
end
```

For every `assert_not_`, there is also a `refute_` variant.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tree-company/pundit_assertions.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
