magento:
  version: 1.8.1.0
  locale: en_US
  timezone: America/Los_Angeles
  default_currency: USD
  db_host: 127.0.0.1
  db_name: wsumage_network
  db_user: mageDbNtkUsr2014
  db_pass: samplepassword
  url: store.mage.dev
  use_rewrites: yes
  skip_url_validation: yes
  use_secure: no
  secure_base_url: ""
  use_secure_admin: no
  admin_firstname: Jeremy
  admin_lastname: Bass
  admin_email: jeremy.bass@wsu.edu
  admin_username: jeremy.bass
  admin_password: demo2014
  sampledate: True 
#{% if grains['env'] == 'vagrant' %}
#{% elif grains['env'] == 'production' %}
#  version: 1.8.1.0
#  locale: en_US
#  timezone: America/Los_Angeles
#  default_currency: USD
#  db_host: localhost
#  db_name: 
#  db_user: 
#  db_pass: 
#  url: store.wsu.edu
#  use_rewrites: yes
#  skip_url_validation: yes
#  use_secure: no
#  secure_base_url: ""
#  use_secure_admin: no
#  admin_firstname: Jeremy
#  admin_lastname: Bass
#  admin_email: jeremy.bass@wsu.edu
#  admin_username: jeremy.bass
#  admin_password: demo2014
#  sampledate: True 
#{%- endif %}