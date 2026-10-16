# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store(:cookie_store, key: '_example_session', expire_after: 14.days)
require_relative "#{File.join(File.dirname(__FILE__), '../../lib/action_dispatch/session/custom_session_store.rb')}"
Rails.application.config.session_store :custom_session_store