MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.cc.flags << '-DGTK -DSCI_LEXER'
  spec.add_dependency 'mruby-scintilla-base', github: 'masahino/mruby-scintilla-base'
  spec.version = '5.3.8'

  def spec.download_scintilla
    require 'open-uri'
    scintilla_ver = '538'
    lexilla_ver = '528'

    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    lexilla_url = "https://scintilla.org/lexilla#{lexilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    scintilla_a = "#{scintilla_dir}/bin/scintilla.a"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    lexilla_a = "#{lexilla_dir}/bin/liblexilla.a"
    lexilla_h = "#{lexilla_dir}/include/Lexilla.h"

    file scintilla_h do
      URI.open(scintilla_url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_dir
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write scintilla_tar
        end
      end
    end

    file scintilla_a => scintilla_h do
      sh %Q{(cd #{scintilla_dir}/gtk && make GTK3=1 CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    file lexilla_h do
      URI.open(lexilla_url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        lexilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write lexilla_tar
        end
      end
    end

    file lexilla_a => lexilla_h do
      sh %Q{(cd #{lexilla_dir}/src && make CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    file "#{dir}/src/scintilla-gtk.c" => [scintilla_a, lexilla_a]

    linker.flags_before_libraries << scintilla_a
    linker.flags_before_libraries << lexilla_a
    [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |cc|
      cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
      if build.kind_of?(MRuby::CrossBuild) && %w(x86_64-apple-darwin14).include?(build.host_target)
        cc.flags << `-framework Cocoa`
      end
      cc.include_paths << "#{scintilla_dir}/include"
      cc.include_paths << "#{scintilla_dir}/src"
      cc.include_paths << "#{lexilla_dir}/include"
    end
    linker.flags_before_libraries << `pkg-config --libs gmodule-2.0 gtk+-3.0`.chomp
  end
#  spec.cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
  spec.download_scintilla
end
