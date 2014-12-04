$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "monster_cap/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "monster-cap"
  s.version     = MonsterCap::VERSION
  s.authors     = ['Monsterbox Productions']
  s.email       = ['tye@monsterboxpro.com']
  s.homepage    = 'http://monsterboxpro.com'
  s.summary     = 'monsterbox capistrano tasks'
  s.description = 'monsterbox capistrano tasks'
  s.license     = 'MIT'

  s.files = Dir["{lib}/**/*", "MIT-LICENSE"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
end
