
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "als"
  spec.version       = "0.0.1"
  spec.authors       = ["Will Munn", "Hilke Ros"]

  spec.summary       = 'Parser for ableton live sets'
  spec.homepage      = "https://github.com/willm/als"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_runtime_dependency "nokogiri", "~> 1.8"
end
