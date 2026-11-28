# frozen_string_literal: true

require "capybara/selenium/driver"

# Capybara 3.40 clears storage with an origin Chrome 158 no longer accepts.
# https://github.com/teamcapybara/capybara/issues/2865
module ChromeStorageReset
  private

  # Capybara のワイルドカード指定を Cookie の全消去とアプリのオリジンの消去に置き換える。
  def execute_cdp(command, params = {})
    return super unless command == "Storage.clearDataForOrigin" && params[:origin] == "*"

    storage_types = params.fetch(:storageTypes).split(",")
    super("Network.clearBrowserCookies") if storage_types.delete("cookies")

    origin = Capybara.current_session.server&.base_url
    return if origin.nil? || storage_types.empty?

    super(command, origin: origin, storageTypes: storage_types.join(","))
  end
end

if Gem.loaded_specs.fetch("capybara").version == Gem::Version.new("3.40.0")
  Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
end
