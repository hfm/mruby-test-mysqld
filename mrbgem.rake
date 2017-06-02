MRuby::Gem::Specification.new('mruby-test-mysqld') do |spec|
  spec.license = 'MIT'
  spec.authors = 'OKUMURA Takahiro'
  spec.version = '0.0.2'

  spec.add_dependency 'mruby-io'
  spec.add_dependency 'mruby-dir'
  spec.add_dependency 'mruby-tempfile'
  spec.add_dependency 'mruby-mysql'
  spec.add_dependency 'mruby-process'
  spec.add_dependency 'mruby-exec', github: 'haconiwa/mruby-exec'
  spec.add_dependency 'mruby-at_exit'
  spec.add_dependency 'mruby-onig-regexp'
  spec.add_dependency 'mruby-versioncmp', github: 'hfm/mruby-versioncmp'
end
