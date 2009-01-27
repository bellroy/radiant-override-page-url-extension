namespace :radiant do
  namespace :extensions do
    namespace :url_override_extension do
      
      desc "Runs the migration of the Url Override extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          UrlOverrideExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          UrlOverrideExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Url Override to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[UrlOverrideExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(UrlOverrideExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
