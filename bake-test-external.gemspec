# frozen_string_literal: true

require_relative "lib/bake/test/external/version"

Gem::Specification.new do |spec|
	spec.name = "bake-test-external"
	spec.version = Bake::Test::External::VERSION
	
	spec.summary = "Run external test suites to check for breakage."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/bake-test-external"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{bake,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "bake"
	
	spec.add_development_dependency "rspec"
end
