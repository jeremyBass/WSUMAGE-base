{% set MAGE = pillars.magento -%}
{% set DB = pillars.database -%}
{% if MAGE.url -%}
    {% set URL = MAGE.url -%}
{% else -%}
    {% set URL = "http://store.mage.dev" -%}
{% endif -%}
magento:
  mode: {{ MAGE.mode if MAGE.mode else "default" }}
  sample_data: {{ MAGE.sample_data if MAGE.sample_data else "True" }}
  sample_stores: {{ MAGE.sample_stores if MAGE.sample_stores else "True" }}
  overload_settings: {{ MAGE.overload_settings if MAGE.overload_settings else "True" }}
  version: {{ MAGE.version if MAGE.version else "2.0.0" }}
  admin-firstname: {{ MAGE.admin_firstname if MAGE.admin_firstname else "Admin" }}
  admin-lastname: {{ MAGE.admin_lastname if MAGE.admin_lastname else "istrator" }}
  admin-email: {{ MAGE.admin_email if MAGE.admin_email else "web.support@wsu.edu" }}
  admin-user: {{ MAGE.admin_username if MAGE.admin_username else "admin" }}
  admin-password: {{ MAGE.admin_password if MAGE.admin_password else "demo2014" }}
  base-url: {{ MAGE.baseurl if MAGE.baseurl else "mage.dev" }}
  url: {{ URL }}
  backend-frontname: {{ MAGE.backend_frontname if MAGE.backend_frontname else "mage_backend" }}
  language: {{ MAGE.locale if MAGE.locale else "en_US" }}
  currency: {{ MAGE.default_currency if MAGE.default_currency else "USD" }}
  timezone: {{ MAGE.timezone if MAGE.timezone else "America/Los_Angeles" }}
  use-rewrites: {{ MAGE.use_rewrites if MAGE.use_rewrites else "1" }}
  use-secure: {{ MAGE.use_secure if MAGE.use_secure else "0" }}
  base-url-secure: {{ MAGE.secure_base_url if MAGE.secure_base_url else URL }}
  use-secure-admin: {{ MAGE.use_secure_admin if MAGE.use_secure_admin else "0" }}
  admin-use-security-key: {{ MAGE.admin-use-security-key if MAGE.use_secure_admin else "1" }}
  session-save: {{ MAGE.session-save if MAGE.use_secure_admin else "files" }}
  key: {{ MAGE.crypt_key if MAGE.crypt_key else "a723ebb767352a1f2cf5036b95e4b367" }}
  cleanup-database: {{ MAGE.cleanup-database if MAGE.cleanup-database else "0" }}
  db-init-statements: {{ MAGE.db-init-statements if MAGE.db-init-statements else "SET NAMES utf8;" }}
  sales-order-increment-prefix: {{ MAGE.sales-order-increment-prefix if MAGE.sales-order-increment-prefix else "wsumarket_" }}
  db-host: {{ DB.host if DB.host else "127.0.0.1" }}
  db-name: {{ DB.name if DB.name else "wsumage_networks" }}
  db-user: {{ DB.user if DB.user else "mageNtkUsr2014" }}
  db-password: {{ DB.pass if DB.pass else "VAGRANT" }}
  db-prefix: {{ DB.prefix if DB.prefix else "mage_" }}
  trim_defaultext: {{ MAGE.trim_defaultext if MAGE.trim_defaultext else "True" }}
  db_restore_host: {{ MAGE.db_restore_host if MAGE.db_restore_host else "" }}
  db_restore_user: {{ MAGE.db_restore_user if MAGE.db_restore_user else "" }}
  db_restore_pass: {{ MAGE.db_restore_pass if MAGE.db_restore_pass else "" }}
  db_restore_db: {{ MAGE.db_restore_db if MAGE.db_restore_db else "" }}
  