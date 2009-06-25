(in /Users/hinmanm/src/ruby/forkify)
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{forkify}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lee Hinman"]
  s.date = %q{2009-06-23}
  s.description = %q{forkify.rb makes it easy to process a bunch of data using 'n'
  worker processes. It is based off of forkoff and threadify by Ara Howard.
  It aims to be safe to use on Ruby 1.8.6+ and Ruby 1.9.1+}
  s.email = ["lee@writequit.org"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/forkify.rb", "test/test_forkify.rb", "examples/a.rb", "examples/b.rb"]
  s.homepage = %q{http://github.com/dakrone/forkify}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{writequit}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{forkify.rb makes it easy to process a bunch of data using 'n' worker processes}
  s.test_files = ["test/test_forkify.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.0.0"])
    else
      s.add_dependency(%q<hoe>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.0.0"])
  end
end
