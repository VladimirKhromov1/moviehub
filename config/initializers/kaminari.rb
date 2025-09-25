# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 20
  config.max_per_page = 100
  config.window = 2
  config.outer_window = 1
end