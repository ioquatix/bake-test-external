# frozen_string_literal: true

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

	input.each do |key, config|
		config.transform_keys!(&:to_sym);

		url = config[:url]
		command = config.fetch(:command, DEFAULT_COMMAND)

		Bundler.with_unbundled_env do
			clone_and_test(gemspec.name, key, url, command)
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

def clone_and_test(name, key, url, command)
	require 'fileutils'
	
	path = "external/#{key}"
	
	unless File.directory?(path)
		FileUtils.mkdir_p path
		system("git", "clone", url, path)

		# I tried using `bundle config --local local.async ../` but it simply doesn't work.
		# system("bundle", "config", "--local", "local.async", __dir__, chdir: path)
		
		gemfile_paths = ["#{path}/Gemfile", "#{path}/gems.rb"]
		gemfile_path = gemfile_paths.find{|path| File.exist?(path)}
		
		File.open(gemfile_path, "a") do |file| 
			file.puts nil, "# Added by external testing:"
			file.puts("gem #{name.to_s.dump}, path: '../../'")
		end

		system("bundle", "install", chdir: path)
	end

	system(*command, chdir: path) or abort("External tests #{key} failed!")
end
