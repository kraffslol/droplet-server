# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Droplet::Application.config.secret_key_base = 'e682e967fa403d7a7684a48e25695a7a130ad71dfc6cf1f246e304a688ff2a9614dd25fefe3cf9e4aa3f594cb468bb7834547ba78d4f0915eb70b5ac2c4b14e4'
