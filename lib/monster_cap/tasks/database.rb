require 'tempfile'
namespace :db do
  desc 'Pull the remote database to your local database'
  task :pull do
    on primary :db do |host|
      SSHKit.config.output_verbosity = Logger::INFO
      database_yml = ''
      within current_path do
        database_yml = capture(:cat, 'config/database.yml')
      end
      database_config = YAML.load(database_yml)
      remote_database = database_config[fetch(:rails_env).to_s]
      local_database = database_config['development']
      case remote_database['adapter']
      when 'postgresql'
        info "Dumping remote database..."
        remote_file = "/tmp/db.#{Time.now.to_f}-#{rand(99999999999).to_s}.bz2"
        execute "pg_dump -c -U #{remote_database['username']} #{remote_database['database']} | bzip2 -9 > #{remote_file}"
        fh = Tempfile.new('db')
        fh.close
        download! remote_file, fh.path
        info "Importing database..."
        info "bzip2 -cd #{fh.path} | psql -U #{local_database['username']} -d #{local_database['database']}"
        system "bzip2 -cd #{fh.path} | psql -U #{local_database['username']} -d #{local_database['database']}"
        fh.unlink
        execute "rm #{remote_file}"
      else
        raise "Adapter #{database_config['adapter']} not supported."
      end
    end
  end
  desc 'Push your local database to the remote database'
  task :push do
    on primary :db do |host|
      database_yml = ''
      within current_path do
        database_yml = capture(:cat, 'config/database.yml')
      end
      database_config = YAML.load(database_yml)
      remote_database = database_config[fetch(:rails_env).to_s]
      local_database = database_config['development']
      puts "             \e[31;40m######################################################"
      puts "             #      \e[5m*WARNING*\e[25m      \e[5m*WARNING*\e[25m      \e[5m*WARNING*\e[25m       #"
      puts "             # Are you sure you want to \e[1mERASE THE REMOTE DATABASE\e[22m #"
      puts "             #     mand replace it with your local database?      #"
      puts "             #                    yes / no                        #"
      puts "             ######################################################\e[0m"
      input = STDIN.gets.chomp
      exit if input != 'yes'
      case remote_database['adapter']
      when 'postgresql'
        info "Dumping local database..."
        fh = Tempfile.new('db')
        fh.close
        system "pg_dump -c -U #{local_database['username']} #{local_database['database']} | bzip2 -9 > #{fh.path}"
        remote_file = "/tmp/db.#{Time.now.to_f}-#{rand(99999999999).to_s}.bz2"
        upload! fh.path, remote_file
        info "Importing database..."
        execute "bzip2 -cd #{remote_file} | psql -U #{remote_database['username']} -d #{remote_database['database']}"
        fh.unlink
        execute "rm #{remote_file}"
      else
        raise "Adapter #{database_config['adapter']} not supported."
      end
    end
  end
end
