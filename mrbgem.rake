MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.cc.flags << "-DGTK -DSCI_LEXER"
  spec.add_dependency 'mruby-scintilla-base', :github => 'masahino/mruby-scintilla-base', :branch => "scintilla5"
  spec.version = '5.1.0'

  def spec.download_scintilla
    require 'open-uri'
    scintilla_ver='510'

    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    lexilla_url = "https://scintilla.org/lexilla#{scintilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    scintilla_a = "#{scintilla_dir}/bin/scintilla.a"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    lexilla_a = "#{lexilla_dir}/bin/liblexilla.a"

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

    unless File.exists?(lexilla_a)
      unless Dir.exist?(lexilla_dir)
        URI.open(lexilla_url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
          lexilla_tar = http.read
          FileUtils.mkdir_p scintilla_build_root
          IO.popen("tar xfz - -C #{filename scintilla_build_root}", "wb") do |f|
            f.write lexilla_tar
          end
        end
      end
      sh %Q{(cd #{lexilla_dir}/src && make CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    self.linker.flags_before_libraries << scintilla_a
    self.linker.flags_before_libraries << lexilla_a
    [self.cc, self.cxx, self.objc, self.mruby.cc, self.mruby.cxx, self.mruby.objc].each do |cc|
      cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
      if build.kind_of?(MRuby::CrossBuild) && %w(x86_64-apple-darwin14).include?(build.host_target)
        cc.flags << `-framework Cocoa`
      end
      cc.include_paths << scintilla_dir+"/include"
      cc.include_paths << scintilla_dir+"/src"
      cc.include_paths << lexilla_dir + "/include"
    end
  end

end
