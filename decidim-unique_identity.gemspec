# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/unique_identity/version"

Gem::Specification.new do |s|
  s.version = Decidim::UniqueIdentity.version
  s.authors = ["Armand"]
  s.email = ["fardeauarmand@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-unique_identity"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-unique_identity"
  s.summary = "A decidim unique_identity module"
  s.description = "Unique identity authorization handler."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::UniqueIdentity.version
end
