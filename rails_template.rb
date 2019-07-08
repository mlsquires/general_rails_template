require 'shellwords'
require 'tmpdir'
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
# Thanks @mattbrictson!
#
def current_directory
  @current_directory ||=
    if __FILE__ =~ %r{\Ahttps?://}
      tempdir = Dir.mktmpdir("general_rails_template-")
      at_exit { FileUtils.remove_entry(tempdir) }
      git :clone => [
        "--quiet",
        "https://github.com/mlsquires/general_rails_template.git",
        tempdir
      ].map(&:shellescape).join(" ")

      tempdir
    else
      File.expand_path(File.dirname(__FILE__))
    end
end

#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
#
def source_paths
  Array(super) + [current_directory]
end

remove_file "README.md"
template "templates/README.md.tt", "README.md"

remove_file "Gemfile"
copy_file "templates/Gemfile", "Gemfile"

remove_file ".gitignore"
copy_file "templates/gitignore", ".gitignore"
copy_file "templates/CHANGELOG.md", "CHANGELOG.md"

remove_file "config/database.yml"
#template "templates/config/database_postgres.yml.tt", "config/database.yml"
template "templates/config/database_mysql.yml.tt", "config/database.yml"

# template "templates/Dockerfile.tt", "Dockerfile"

after_bundle do
  # the .bundle/config has BUNDLE_DISABLE_SHARED_GEMS set to false,
  # which installs/uses gems from their standard version (e.g.,
  # system ruby, rbenv version, etc).
  #
  # If you are using Docker or if you don't mind sharing gems
  # on a system, this is what you want. If you want to isolate
  # your application from others on your system, change this
  # to true
  #
#  empty_directory ".bundle"
#  copy_file "templates/bundle_config", ".bundle/config"

  remove_dir "test"

  run "spring stop"
  generate "rspec:install"
  generate "serviceworker:install"

  run "bundle exec guard init"
  remove_file ".rubocop.yml"
  copy_file "templates/rubocop.yml", ".rubocop.yml"

  template "templates/dotenv.tt", "dotenv.sample"
  template "templates/dotenv.tt", ".env"

  empty_directory "script"
  copy_file "templates/script/create_things.sh", "script/create_things.sh"
  chmod "script/create_things.sh", 0755
  copy_file "templates/script/create_database_user.sh", "script/create_database_user.sh"
  chmod "script/create_database_user.sh", 0755
  template "templates/script/postgres_user_create.sql.tt", "script/postgres_user_create.sql"

  empty_directory "spec/support"
  copy_file "templates/spec/support/factory_bot.rb", "spec/support/factory_bot.rb"


#  git :init
#  git add: "."
#  git commit: "-a -m 'Initial commit'"
end
