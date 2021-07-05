MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'

  conf.gem :github => 'masahino/mruby-scintilla-base' do |g|
    g.download_scintilla
  end
  conf.gem File.expand_path(File.dirname(__FILE__)) do |g|
    g.cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
    g.download_scintilla
    g.linker.flags_before_libraries << `pkg-config --libs gmodule-2.0 gtk+-3.0`.chomp
  end

  conf.enable_test
  conf.enable_bintest
  conf.linker do |linker|
    linker.libraries << "stdc++"
  end
end
