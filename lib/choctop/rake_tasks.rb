module ChocTop
  module RakeTasks
    def define_tasks
      return unless Object.const_defined?("Rake")

      desc "Build Xcode #{build_type}"
      task :build => "build/#{build_type}/#{target}/Contents/Info.plist"

      task "build/#{build_type}/#{target}/Contents/Info.plist" do
        make_build
      end

      desc "Create the dmg file for appcasting"
      task :dmg => :build do
        detach_dmg
        make_dmg
        detach_dmg
        convert_dmg_readonly
        add_eula
      end

      desc "Create/update the appcast file"
      task :feed do
        make_appcast
        make_dmg_symlink
        make_index_redirect
        make_release_notes
      end

      desc "Upload the appcast file to the host"
      task :upload => :feed do
        upload_appcast
      end

      task :detach_dmg do
        detach_dmg
      end

      task :size do
        puts configure_dmg_window
      end

      namespace :version do
        desc "Display the current version"
        task :current do
          puts VersionHelper.new(info_plist_path).to_s
        end

        namespace :bump do
          desc "Bump the gemspec by a major version."
          task :major do
            VersionHelper.new(info_plist_path) do |version|
              version.bump_major
            end
          end

          desc "Bump the gemspec by a minor version."
          task :minor do
            VersionHelper.new(info_plist_path) do |version|
              version.bump_minor
            end
          end

          desc "Bump the gemspec by a patch version."
          task :patch do
            VersionHelper.new(info_plist_path) do |version|
              version.bump_patch
            end
          end
        end
      end
    end
  end
end