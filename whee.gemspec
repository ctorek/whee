Gem::Specification.new do |s|
  s.name = "whee"
  s.version = "0.1.0"
  s.license = "GPL-3.0-or-later"
  s.summary = "a faster deploy tool for FRC"
  s.authors = ["Ell Torek"]
  s.email = "ctorek@proton.me"
  s.files = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.executables << 'whee'
  s.homepage = "https://github.com/ctorek/whee"
end
