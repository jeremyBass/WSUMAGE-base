magento:
  admin_firstname: Jeremy
  admin_lastname: Bass
  admin_email: jeremy.bass@wsu.edu
  admin_username: admin
  admin_password: demo2014
  sample_data: True
  sample_stores: True
  #it should be noted that you will most likely not need anything below
  version: 1.8.1.0
  admin_route: admin
  locale: en_US
  timezone: America/Los_Angeles
  default_currency: USD
  url: store.mage.dev
  use_rewrites: yes
  skip_url_validation: yes
  use_secure: no
  secure_base_url: ""
  use_secure_admin: no
#{% if grains['env'] == 'vagrant' %}
#{% elif grains['env'] == 'production' %}
#{%- endif %}