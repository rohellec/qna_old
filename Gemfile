source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1.3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.1.6'
# Use jQuery as JavaScript library
gem 'jquery-rails', '~> 4.3.1'
# Use Slim as template engine
gem 'slim-rails', '~> 3.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'carrierwave', '~> 1.3.1'
gem 'cocoon', '~> 1.2.11'
gem 'devise', '~> 4.5.0'
gem 'gon', '~> 6.2.1'
gem 'skim', '~> 0.10.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'rspec-rails', '~> 3.8.1'
  gem 'factory_bot_rails', '~> 4.11.1'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 10.0'
  gem 'dotenv-rails', '~> 2.5'
end

group :test do
  gem 'capybara', '~> 3.12'
  gem 'capybara-webkit', '~> 1.15.0'
  gem 'database_cleaner', '~> 1.7'
  gem 'launchy', '~> 2.4.3'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'shoulda-matchers', '~> 3.1.2'
  gem 'with_model', '~> 2.1.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '~> 3.5'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
