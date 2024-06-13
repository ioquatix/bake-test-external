# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.
# Copyright, 2022, by Akshay Birajdar.
# Copyright, 2022, by Hiroaki Osawa.

DEFAULT_EXTERNALS_PATH = 'config/external.yaml'
DEFAULT_COMMAND = "bake test"

# Run external tests.
# @parameter gemspec [String] The input gemspec path.
def external(input: nil, gemspec: self.find_gemspec)
	require 'bundler'
	require 'yaml'
	
	if input.nil? and File.exist?(DEFAULT_EXTERNALS_PATH)
		# symbolize_names is unsupported on Ruby 2.7
		input = YAML.load_file(DEFAULT_EXTERNALS_PATH) # , symbolize_names: true)
	end
	
	input&.each do |key, config|
		config = config.transform_keys(&:to_sym)
		config[:env] ||= {}
		
		Bundler.with_unbundled_env do
			clone_and_test(gemspec.name, key, config)
		end
	end
end

private

def find_gemspec(glob = "*.gemspec")
	paths = Dir.glob(glob, base: @root).sort
	
	if paths.size > 1
		raise "Multiple gemspecs found: #{paths}, please specify one!"
	end
	
	if path = paths.first
		return ::Gem::Specification.load(path)
	end
end

def clone_and_test(name, key, config)
	path = clone_repository(name, key, config)
	
	test_repository(path, config) or abort("External tests #{key} failed!")
end

def clone_repository(name, key, config)
	require 'fileutils'
	
	url = config[:url]
	
	path = "external/#{key}"
	
	unless File.directory?(path)
		FileUtils.mkdir_p path
		command = ["git", "clone", "--depth", "1"]
		
		if branch = config[:branch]
			command << "--branch" << branch
		end
		
		if tag = config[:tag]
			command << "--tag" << tag
		end
		
		command << url << path
		system(config[:env], *command)
		
		# I tried using `bundle config --local local.async ../` but it simply doesn't work.
		# system("bundle", "config", "--local", "local.async", __dir__, chdir: path)
		
		gemfile_path = self.gemfile_path(path, config)
		
		File.open(gemfile_path, 'r+') do |file|
			pattern = /gem.*?['"]#{name}['"]/
			lines = file.grep_v(pattern)

			file.seek(0)
			file.truncate(0)
			file.puts(lines)
			file.puts nil, "# Added by external testing:"
			file.puts("gem #{name.to_s.dump}, path: '../../'")

			config[:extra]&.each do |line|
				file.puts(line)
			end
		end

		system(config[:env], "bundle", "install", chdir: path)
	end
	
	return path
end

def test_repository(path, config)
	command = config.fetch(:command, DEFAULT_COMMAND)
	
	Array(command).each do |line|
		system(config[:env], *line, chdir: path)
	end
end

GEMFILE_NAMES = ["Gemfile", "gems.rb"]

def resolve_gemfile_path(root, config)
	if config_path = config[:gemfile]
		path = File.join(root, config_path)
		
		unless File.exist?(path)
			raise ArgumentError, "Specified gemfile path does not exist: #{config_path.inspect}!"
		end
		
		# We consider this to be a custom gemfile path:
		return false, path
	end
	
	GEMFILE_NAMES.each do |name|
		path = File.join(root, name)
		
		if File.exist?(path)
			# We consider this to be a default gemfile path:
			return true, path
		end
	end
	
	raise ArgumentError, "Could not find gem file in #{root.inspect}!"
end

def gemfile_path(root, config)
	config.fetch(:cached_gemfile_path) do
		root = File.expand_path(root, @root)
		default, path = self.resolve_gemfile_path(root, config)
		
		config[:cached_gemfile_path] = path
		
		# Custom gemfile paths should be set explicitly:
		unless default
			config[:env]['BUNDLE_GEMFILE'] = path
		end
		
		return path
	end
end
