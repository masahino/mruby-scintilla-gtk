MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.add_dependency('mruby-gtk3')
  spec.add_dependency('mruby-scintilla-base')
  spec.cc.flags << "-DGTK -DSCI_LEXER"

  def spec.download_scintilla
    require 'open-uri'
    scintilla_ver='366'
    scinterm_ver='1.8'
    scintilla_url = "http://www.scintilla.org/scintilla#{scintilla_ver}.tgz"
    scintilla_dir = "#{build_dir}/scintilla"
    scintilla_a = "#{scintilla_dir}/scintilla/bin/scintilla.a"

    unless File.exists?(scintilla_a)
      open(scintilla_url, 'Accept-Encoding' => '') do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_dir
        IO.popen("tar xfz - -C #{filename scintilla_dir}", "w") do |f|
          f.write scintilla_tar
        end
      end
      sh %Q{(cd #{scintilla_dir}/scintilla/gtk && make GTK3=1 CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    self.linker.flags_before_libraries << scintilla_a
    [self.cc, self.cxx, self.objc, self.mruby.cc, self.mruby.cxx, self.mruby.objc].each do |cc|
      cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
      if build.kind_of?(MRuby::CrossBuild) && %w(x86_64-apple-darwin14).include?(build.host_target)
        cc.flags << `-framework Cocoa`
      end
      cc.include_paths << scintilla_dir+"/scintilla/include"
      cc.include_paths << scintilla_dir+"/scintilla/src"
    end
  end

end
