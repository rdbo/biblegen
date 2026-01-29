Gem::Specification.new do |s|
  s.name          = 'biblegen'
  s.version       = '1.1.0'
  s.summary       = 'A Catholic Bible generator'
  s.description   = 'Generate and parse the Catholic Bible in different formats'
  s.authors       = ['Rdbo']
  s.email         = ['rdbodev@gmail.com']
  s.files         = Dir.glob('lib/**/*') + ['README.md', 'LICENSE']
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/rdbo/biblegen'
  s.license       = 'AGPL-3.0'
end
