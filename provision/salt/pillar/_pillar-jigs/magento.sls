{% set pillar = pillars.magento -%}
magento:
  admin_firstname: {{ pillar.admin_firstname if pillar.admin_firstname else "Admin" }}
  admin_lastname: {{ pillar.admin_lastname if pillar.admin_lastname else "istrator" }}
  admin_email: {{ pillar.admin_email if pillar.admin_email else "admin@mage.dev" }}
  admin_username: {{ pillar.admin_username if pillar.admin_username else "admin" }}
  admin_password: {{ pillar.admin_password if pillar.admin_password else "demo2014" }}
  sample_data: {{ pillar.sample_data if pillar.sample_data else "True" }}
  sample_stores: {{ pillar.sample_stores if pillar.sample_stores else "True" }}
  version: {{ pillar.version if pillar.version else "1.9.1.0" }}
  admin_route: {{ pillar.admin_route if pillar.admin_route else "admin" }}
  locale: {{ pillar.locale if pillar.locale else "en_US" }}
  timezone: {{ pillar.timezone if pillar.timezone else "America/Los_Angeles" }}
  default_currency: {{ pillar.default_currency if pillar.default_currency else "USD" }}
  url: {{ pillar.url if pillar.url else "store.mage.dev" }}
  use_rewrites: {{ pillar.use_rewrites if pillar.use_rewrites else "yes" }}
  skip_url_validation: {{ pillar.skip_url_validation if pillar.skip_url_validation else "yes" }}
  use_secure: {{ pillar.use_secure if pillar.use_secure else "no" }}
  secure_base_url: {{ pillar.secure_base_url if pillar.secure_base_url else "" }}
  use_secure_admin: {{ pillar.use_secure_admin if pillar.use_secure_admin else "no" }}
