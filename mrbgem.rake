MRuby::Gem::Specification.new('mruby-scintilla-gtk') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.cc.flags << '-DGTK -DSCI_LEXER'
  spec.add_dependency 'mruby-scintilla-base', github: 'masahino/mruby-scintilla-base'
  spec.version = '5.6.6'

  def spec.download_scintilla
    return if @scintilla_download_configured

    @scintilla_download_configured = true
    require 'open-uri'
    scintilla_ver = '566'

    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    scintilla_a = "#{scintilla_dir}/bin/scintilla.a"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"

    file scintilla_h do
      URI.open(scintilla_url, open_timeout: 10, read_timeout: 30) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_dir
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write scintilla_tar
        end
        raise "tar failed: #{scintilla_url} (#{$?.exitstatus})" unless $?.success?
      end
      raise "#{scintilla_h} not produced" unless File.exist?(scintilla_h)
    end

    file scintilla_a => scintilla_h do
      sh %Q{(cd #{scintilla_dir}/gtk && make GTK3=1 CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |compiler|
      compiler.flags << `pkg-config --cflags gtk+-3.0`.chomp
      if build.kind_of?(MRuby::CrossBuild) && %w(x86_64-apple-darwin14).include?(build.host_target)
        compiler.flags << `-framework Cocoa`
        compiler.flags << `pkg-config --cflags gtk-mac-integration-gtk3`.chomp
      end
      compiler.include_paths << "#{scintilla_dir}/include"
      compiler.include_paths << "#{scintilla_dir}/src"
    end
    file "#{dir}/src/scintilla-gtk.c" => [scintilla_a]

    linker.flags_before_libraries << scintilla_a
    linker.flags_before_libraries << `pkg-config --libs gmodule-2.0 gtk+-3.0`.chomp
  end
  # spec.cc.flags << `pkg-config --cflags gtk+-3.0`.chomp
  spec.download_scintilla
end
