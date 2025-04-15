# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.
# Copyright, 2022, by Akshay Birajdar.
# Copyright, 2022, by Hiroaki Osawa.

def initialize(context)
	super
	
	require "bake/test/external"
	require "bundler"
	require "yaml"
end

DEFAULT_EXTERNALS_PATH = "config/external.yaml"

# Run external tests.
# @parameter gemspec [String] The input gemspec path.
def external(input: nil, gemspec: nil)
	# Prepare the project for testing, e.g. build native extensions, etc.
	context["before_test"]&.call
	
	input ||= default_input
	
	controller = Bake::Test::External::Controller.new
	gemspec ||= controller.find_gemspec
	
	input&.each do |key, config|
		config = config.transform_keys(&:to_sym)
		config[:env] ||= {}
		
		Bundler.with_unbundled_env do
			controller.clone_and_test(gemspec.name, key, config)
		end
	end
end

def clone(input: nil, gemspec: nil)
	input ||= default_input
	
	controller = Bake::Test::External::Controller.new
	gemspec ||= controller.find_gemspec
	
	input&.each do |key, config|
		config = config.transform_keys(&:to_sym)
		config[:env] ||= {}
		
		controller.clone_repository(gemspec.name, key, config)
	end
end

private

def default_input
	if File.exist?(DEFAULT_EXTERNALS_PATH)
		YAML.load_file(DEFAULT_EXTERNALS_PATH)
	end
end
