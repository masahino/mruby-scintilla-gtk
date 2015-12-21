MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.add_dependency('mruby-gtk2')
  spec.add_dependency('mruby-scintilla-base')
  spec.cc.flags << "-DGTK -DSCI_LEXER"
end
