# frozen_string_literal: true

require_relative "lib/bake/test/external/version"

Gem::Specification.new do |spec|
	spec.name = "bake-test-external"
	spec.version = Bake::Test::External::VERSION
	
	spec.summary = "Run external test suites to check for breakage."
	spec.authors = ["Samuel Williams", "Akshay Birajdar", "Hiroaki Osawa"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/bake-test-external"
	
	spec.metadata = {
		"documentation_uri" => "https://ioquatix.github.io/bake-test-external/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/bake-test-external.git",
	}
	
	spec.files = Dir.glob(['{bake,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "bake"
end
