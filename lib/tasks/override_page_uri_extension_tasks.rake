namespace :radiant do
  namespace :extensions do
    namespace :override_page_uri do
      
      desc "Runs the migration of the Override Page Uri extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          OverridePageUriExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          OverridePageUriExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Override Page Uri to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[OverridePageUriExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(OverridePageUriExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
