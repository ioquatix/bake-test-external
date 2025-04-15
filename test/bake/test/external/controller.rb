# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "bake/test/external/controller"

describe Bake::Test::External::Controller do
	let(:root) {File.expand_path("../../../..", __dir__)}
	let(:controller) {subject.new(root)}
	
	it "can find gemspec" do
		gemspec = controller.find_gemspec
		
		expect(gemspec).to be_a(Gem::Specification)
		expect(gemspec.name).to be == "bake-test-external"
	end
end
