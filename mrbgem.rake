MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.add_dependency('mruby-scintilla-base')
  spec.cc.flags << "-DGTK -DSCI_LEXER"

  def spec.download_scintilla
    require 'open-uri'
    scintilla_ver='380'
    scintilla_url = "https://downloads.sourceforge.net/scintilla/scintilla#{scintilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla"
    scintilla_dir = "#{scintilla_build_root}/scintilla#{scintilla_ver}"
    scintilla_a = "#{scintilla_dir}/bin/scintilla.a"

    unless File.exists?(scintilla_a)
      unless Dir.exist?(scintilla_dir)
        open(scintilla_url) do |http|
          scintilla_tar = http.read
          FileUtils.mkdir_p scintilla_dir
          IO.popen("tar xfz - -C #{filename scintilla_build_root}", "w") do |f|
            f.write scintilla_tar
          end
        end
      end
      sh %Q{(cd #{scintilla_dir}/gtk && make GTK3=1 CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    self.linker.flags_before_libraries << scintilla_a
    [self.cc, self.cxx, self.objc, self.mruby.cc, self.mruby.cxx, self.mruby.objc].each do |cc|
      cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
      if build.kind_of?(MRuby::CrossBuild) && %w(x86_64-apple-darwin14).include?(build.host_target)
        cc.flags << `-framework Cocoa`
      end
      cc.include_paths << scintilla_dir+"/include"
      cc.include_paths << scintilla_dir+"/src"
    end
  end

end
