# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'fileutils'

module Bake
	module Test
		module External
			class Controller
				DEFAULT_COMMAND = "bake test"
				
				def initialize(root = nil)
					@root = root
				end
				
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
					url = config[:url]
					
					path = File.expand_path("external/#{key}", @root)
					
					unless File.directory?(path)
						FileUtils.mkdir_p path
						command = ["git", "clone", "--depth", "1"]
						
						if branch = config[:branch]
							command << "--branch" << branch
						end
						
						command << url << path
						system(*command)
						
						# I tried using `bundle config --local local.async ../` but it simply doesn't work.
						# system("bundle", "config", "--local", "local.async", __dir__, chdir: path)
						
						gemfile_paths = ["#{path}/Gemfile", "#{path}/gems.rb"]
						gemfile_path = gemfile_paths.find{|path| File.exist?(path)}
				
						File.open(gemfile_path, 'r+') do |file|
							pattern = /gem.*?['"]#{name}['"]/
							lines = file.grep_v(pattern)
				
							file.seek(0)
							file.puts(lines)
							file.puts nil, "# Added by external testing:"
							file.puts("gem #{name.to_s.dump}, path: '../../'")
				
							config[:extra]&.each do |line|
								file.puts(line)
							end
						end
				
						system("bundle", "install", chdir: path)
					end
					
					return path
				end
				
				def test_repository(path, config)
					command = config.fetch(:command, DEFAULT_COMMAND)
					
					system(*command, chdir: path)
				end
			end
		end
	end
end
