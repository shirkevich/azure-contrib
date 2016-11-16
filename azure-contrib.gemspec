# -*- encoding: utf-8 -*-
# stub: azure-contrib 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "azure-contrib"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["David Michael"]
  s.date = "2016-10-19"
  s.description = "Extensions to the Azure Ruby SDK - specifically SAS"
  s.email = ["david.michael@giantmachines.com"]
  s.files = [".gitignore", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "azure-contrib.gemspec", "lib/azure-contrib.rb", "lib/azure-contrib/blob_service.rb", "lib/azure-contrib/service_bus_service.rb", "lib/azure-contrib/shared_access_signature.rb", "lib/azure-contrib/version.rb"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Extensions to the Azure Ruby SDK"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<azure>, [">= 0"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_runtime_dependency(%q<celluloid>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<azure>, [">= 0"])
      s.add_dependency(%q<hashie>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<celluloid>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<azure>, [">= 0"])
    s.add_dependency(%q<hashie>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<celluloid>, [">= 0"])
  end
end
