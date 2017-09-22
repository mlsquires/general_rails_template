require 'shellwords'
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

def source_paths
  Array(super) + [current_directory]
end
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.

remove_file "README.md"
template "templates/README.md.tt", "README.md"

copy_file "templates/ruby_version", ".ruby_version"

remove_file "Gemfile"
# set bundler up to install all of the gems in the vendor directory
# disable this while proofing out the template (rebuilding nokigiri
# takes way too long

empty_directory ".bundle"
copy_file "templates/bundle_config", ".bundle/config"

copy_file "templates/Gemfile", "Gemfile"

remove_file ".gitignore"
copy_file "templates/gitignore", ".gitignore"

remove_file "config/database.yml"
template "templates/config/database.yml.tt", "config/database.yml"

after_bundle do
  remove_dir "test"

  run "spring stop"
  run "bundle install"
  generate "rspec:install"
  generate "teaspoon:install"

  run "bundle exec guard init"
  remove_file ".rubocop.yml"
  copy_file "templates/rubocop.yml", ".rubocop.yml"

  template "templates/dotenv.tt", "dotenv.sample"
  template "templates/dotenv.tt", ".env"
  prepend_to_file "dotenv.sample" do <<-EOF
# https://github.com/bkeepers/dotenv
#
# Check this into git (with sensitive information replaced with bogus values)
#
# Perform any addition/deletion of keys in both ".env" and this file.
#
# This has example values for environment variables that the
# application depends on. The actual values are in '.env',
# and you never check that file in.
#
  EOF
  end
  prepend_to_file ".env" do <<-EOF
# https://github.com/bkeepers/dotenv
#
# Perform any addition/deletion of keys in both this file and dotenv.sample
#
# NEVER EVER EVER check this file into source control
#
  EOF
  end

  empty_directory "script"
  copy_file "templates/script/create_things.sh", "script/create_things.sh"
  chmod "script/create_things.sh", 0755
  copy_file "templates/script/create_database_user.sh", "script/create_database_user.sh"
  chmod "script/create_database_user.sh", 0755
  template "templates/script/postgres_user_create.sql.tt", "script/postgres_user_create.sql"

  # Health Check route
  generate(:controller, "health index")
#  route "root to: \"health#index\""

  git :init
  empty_directory ".git/info"
  copy_file "templates/git_info_exclude", ".git/info/exclude"
  git add: "."
  git commit: "-a -m 'Initial commit'"
end

