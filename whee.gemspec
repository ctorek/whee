Gem::Specification.new do |s|
  s.name = "whee"
  s.version = "0.1.1"
  s.license = "GPL-3.0-or-later"
  s.summary = "a faster deploy tool for FRC"
  s.description = <<-EOF
    whee is a command-line program to accelerate the GradleRIO deploy process used in the
    FIRST Robotics Competition. It automatically connects to available robot WiFi networks
    and deploys code.

    whee is still largely untested and is not approved or endorsed by FIRST in any way.
  EOF
  s.authors = ["Ell Torek"]
  s.email = "ctorek@proton.me"
  s.files = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.executables << 'whee'
  s.homepage = "https://github.com/ctorek/whee"
  s.required_ruby_version = '>= 2.7.0'
end
