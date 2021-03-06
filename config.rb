require 'static-sprockets'
require 'lodash-assets'
require 'react-jsx-sprockets'
require 'marbles-js'
require 'marbles-tent-client-js'
require 'raven-js'
require 'icing'
require 'icing/compiler'
require 'contacts-service'
require "cupcake-apps-bar"

ContactsService.configure
StaticSprockets.configure(
  :asset_roots => ["./lib/assets", "./vendor/assets"].concat(ContactsService.settings[:asset_paths]),
  :asset_types => %w( javascripts stylesheets images . ),
  :layout => "./lib/views/application.erb",
  :layout_output_name => 'drop.html',
  :layout_dir => ENV['LAYOUT_DIR'] || "./build",
  :output_dir => ENV['ASSETS_DIR'] || "./build",
  :output_asset_names => %w(
    application.css
    application.js
    moment.js
    react.js
    react-infinite-scroll.js
    raven.js
    contacts_api.js
    marbles.js
    lodash.js
  ).concat(Icing::Compiler::ASSET_NAMES),
  :content_security_policy => {
    'frame-src' => [ENV['CONTACTS_URL'], ENV['CUPCAKE_APPS_BAR_URL'], 'self'].reject { |i| i.nil? }.join(' ')
  }
)

if ENV['SKIP_AUTHENTICATION'].nil? || ENV['SKIP_AUTHENTICATION'] === 'false'
  StaticSprockets.config.merge!(
    :url => ENV['URL'],
    :tent_config => {
      :name => "Files",
      :description => "Web app for uploading files to your Tent server.",
      :display_url => "https://github.com/cupcake/files-web",
      :read_types => %w( https://tent.io/types/relationship/v0),
      :write_types => %w( https://tent.io/types/file/v0 ),
      :scopes => %w( permissions )
    },
    :tent_config_db_path => File.join(File.expand_path(File.join(__FILE__, "..")), "db")
  )

  StaticSprockets.app_config do |app|
    require 'static-sprockets-tent'
    StaticSprocketsTent::App.attach_to_app(app)
  end
end

StaticSprockets.sprockets_config do |environment|
  MarblesJS::Sprockets.setup(environment, vendor: true)
  MarblesTentClientJS::Sprockets.setup(environment)
  RavenJS::Sprockets.setup(environment)
  Icing::Sprockets.setup(environment)
  CupcakeAppsBar::Sprockets.setup(environment)
end
