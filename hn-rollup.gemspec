lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hn/rollup/version"

Gem::Specification.new do |spec|
  spec.name          = "hn-rollup"
  spec.version       = Hn::Rollup::VERSION
  spec.authors       = ["P D"]
  spec.email         = ["partdavid@gmail.com"]

  spec.summary       = %q{Roll up child notes into parent notes in a lightly-structured way}
  spec.description   = File.readlines('README.md').drop_while { |line| line =~ /^(# .*|)$/ }.take_while { |line| line !~ /^#/ }.join('')
  spec.homepage      = "https://github.com/partdavid/hn-rollup"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/partdavid/hn-rollup"
  spec.metadata["changelog_uri"] = "https://github.com/partdavid/hn-rollup/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
