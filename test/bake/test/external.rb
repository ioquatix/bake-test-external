# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "bake"

let(:context) {Bake::Context.load}
let(:external_path) {File.join(context.root, "external/sus")}

it "should clone external repository" do
	context.call("test:external:clone")
	
	expect(File.exist?(external_path)).to be == true
end

it "should run external tests" do
	context.call("test:external")
end
