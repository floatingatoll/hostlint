# -*- ruby -*-

Gem::Specification.new do |spec|
  files = []

  dirs = %w(examples tests)
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name = "hostlint"
  spec.version = "0.0.0"
  spec.summary = "hostlint -- lint for hosts"
  spec.description = "hostlint client"
  spec.license = "Mozilla Public License (1.1)"

  spec.add_dependency("popen4")

  spec.files = files
  spec.bindir = "bin"
  spec.executables << "hostlint"

  spec.authors = ["Wesley Dawson"]
  spec.email = ["wdawson@mozilla.com"]
  spec.homepage = "https://github.com/whd/hostlint"
end
