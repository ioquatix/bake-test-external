require 'bake'

let(:context) {Bake::Context.load}
let(:external_path) {File.join(context.root, "external/bake")}

it "should clone external repository" do
	context.call("test:external", "--input", )
	
	expect(File.exist?(external_path)).to be == true
end
