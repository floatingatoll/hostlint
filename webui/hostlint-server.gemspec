# -*- ruby -*-
require File.join(File.dirname(__FILE__), "VERSION")  # For HOSTLINT_VERSION

Gem::Specification.new do |spec|
  files = ["VERSION.rb"]
  dirs = %w(lib docs examples)
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name = "hostlint-server"
  spec.version = HOSTLINT_VERSION
  spec.summary = "hostlint -- lint for hosts"
  spec.description = "hostlint webui"
  spec.license = "Mozilla Public License (1.1)"

  spec.add_dependency("mongrel")
  spec.add_dependency("rack")
  spec.add_dependency("sinatra")

  spec.files = files
  spec.bindir = "bin"
  spec.executables << "hostlint-server"

  spec.authors = ["Wesley Dawson"]
  spec.email = ["wdawson@mozilla.com"]
  spec.homepage = "https://github.com/whd/hostlint"
end
