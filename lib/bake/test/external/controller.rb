# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'fileutils'
require 'pathname'

module Bake
	module Test
		module External
			class Controller
				DEFAULT_COMMAND = "bake test"
				
				def initialize(root = nil)
					@root = Pathname.new(root || Dir.pwd)
				end
				
				private def system!(*command, **options)
					system(*command, **options, exception: true)
				end
				
				def find_gemspec(pattern = "*.gemspec")
					paths = @root.glob(pattern)
					
					if paths.size > 1
						raise "Multiple gemspecs found: #{paths}, please specify one!"
					end
					
					if path = paths.first
						return ::Gem::Specification.load(path.to_s)
					end
				end
				
				def clone_and_test(name, key, config)
					$stderr.puts "Cloning external repository #{key}..."
					path = clone_repository(name, key, config)
					
					begin
						$stderr.puts "Running external tests #{key}..."
						test_repository(path, config)
					rescue
						$stderr.puts "External tests #{key} failed!"
						raise
					end
				end
				
				def clone_repository(name, key, config)
					url = config[:url]
					
					path = File.join(@root, "external", key)
					
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
						system!(config[:env], *command)
						
						# I tried using `bundle config --local local.async ../` but it simply doesn't work.
						# system!("bundle", "config", "--local", "local.async", __dir__, chdir: path)
						
						gemfile_path = self.gemfile_path(path, config)
						relative_root = @root.relative_path_from(gemfile_path.dirname)
						
						File.open(gemfile_path, 'r+') do |file|
							pattern = /gem.*?['"]#{name}['"]/
							lines = file.grep_v(pattern)
				
							file.seek(0)
							file.truncate(0)
							file.puts(lines)
							file.puts nil, "# Added by external testing:"
							file.puts("gem #{name.to_s.dump}, path: #{relative_root.to_s.dump}")
				
							config[:extra]&.each do |line|
								file.puts(line)
							end
						end
				
						system!(config[:env], "bundle", "install", chdir: path)
					end
					
					return path
				end
				
				def test_repository(path, config)
					command = config.fetch(:command, DEFAULT_COMMAND)
					
					Array(command).each do |line|
						system!(config[:env], *line, chdir: path)
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
						
						# Custom gemfile paths should be set explicitly:
						unless default
							config[:env]['BUNDLE_GEMFILE'] = path
						end
						
						path = Pathname.new(path)
						
						config[:cached_gemfile_path] = path
						
						return path
					end
				end
			end
		end
	end
end
