# frozen_string_literal: true

require_relative 'lib/pundit_assertions/version'

Gem::Specification.new do |spec|
  spec.name = 'pundit_assertions'
  spec.version = PunditAssertions::VERSION
  spec.authors = ['Robbe Van Petegem']
  spec.email = ['git@robbevp.be']

  spec.summary = 'A simple set of minitest assertion to help test pundit policies.'
  spec.homepage = 'https://github.com/tree-company/pundit_assertions'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/tree-company/pundit_assertions'
  spec.metadata['changelog_uri'] = 'https://github.com/tree-company/pundit_assertions/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']
end
