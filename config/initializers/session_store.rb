# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_bitdiddle-sec_session',
  :secret => '3d835c29934fccedaeb9a95f1fcc7bf0da9dbb43f809386df593f3ea53106aa8cf053920d2721c356cf346635d85f57f8f0fe2e941b9904181636836c7858e49'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
