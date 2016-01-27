{% set MAGE = pillars.magento -%}
{% set DB = pillars.database -%}
{% if MAGE.url -%}
    {% set URL = MAGE.url -%}
{% else -%}
    {% set URL = "http://store.mage.dev" -%}
{% endif -%}
{% if MAGE.secure_base_url -%}
    {% set secureURL = MAGE.secure_base_url -%}
{% else -%}
    {% set secureURL = "https://store.mage.dev" -%}
{% endif -%}
magento:
  mode: {{ MAGE.mode if MAGE.mode else "default" }}
  sample_data: {{ MAGE.sample_data if MAGE.sample_data else "True" }}
  sample_stores: {{ MAGE.sample_stores if MAGE.sample_stores else "True" }}
  overload_settings: {{ MAGE.overload_settings if MAGE.overload_settings else "True" }}
  version: {{ MAGE.version if MAGE.version else "2.0.1" }}
  admin_firstname: {{ MAGE.admin_firstname if MAGE.admin_firstname else "Admin" }}
  admin_lastname: {{ MAGE.admin_lastname if MAGE.admin_lastname else "istrator" }}
  admin-email: {{ MAGE.admin_email if MAGE.admin_email else "web.support@wsu.edu" }}
  admin_user: {{ MAGE.admin_username if MAGE.admin_username else "admin" }}
  admin_password: {{ MAGE.admin_password if MAGE.admin_password else "demo2014" }}
  base_url: {{ MAGE.baseurl if MAGE.baseurl else "mage.dev" }}
  url: {{ URL }}
  backend_frontname: {{ MAGE.backend_frontname if MAGE.backend_frontname else "mage_backend" }}
  language: {{ MAGE.locale if MAGE.locale else "en_US" }}
  currency: {{ MAGE.default_currency if MAGE.default_currency else "USD" }}
  timezone: {{ MAGE.timezone if MAGE.timezone else "America/Los_Angeles" }}
  use_rewrites: {{ MAGE.use_rewrites if MAGE.use_rewrites else "1" }}
  use_secure: {{ MAGE.use_secure if MAGE.use_secure else "0" }}
  base_url_secure: {{ secureURL }}
  use_secure_admin: {{ MAGE.use_secure_admin if MAGE.use_secure_admin else "0" }}
  admin_use_security_key: {{ MAGE.admin_use_security_key if MAGE.admin_use_security_key else "1" }}
  session_save: {{ MAGE.session_save if MAGE.session_save else "files" }}
  key: {{ MAGE.crypt_key if MAGE.crypt_key else "a723ebb767352a1f2cf5036b95e4b367" }}
  cleanup_database: {{ MAGE.cleanup_database if MAGE.cleanup_database else "0" }}
  db_init_statements: {{ MAGE.db_init_statements if MAGE.db_init_statements else "SET NAMES utf8;" }}
  sales_order_increment_prefix: {{ MAGE.sales_order_increment_prefix if MAGE.sales_order_increment_prefix else "wsumarket_" }}
  db_host: {{ DB.host if DB.host else "127.0.0.1" }}
  db_name: {{ DB.name if DB.name else "wsumage_networks" }}
  db_user: {{ DB.user if DB.user else "mageNtkUsr2014" }}
  db_password: {{ DB.pass if DB.pass else "VAGRANT" }}
  db_prefix: {{ DB.prefix if DB.prefix else "mage_" }}
  trim_defaultext: {{ MAGE.trim_defaultext if MAGE.trim_defaultext else "True" }}
  db_restore_host: {{ MAGE.db_restore_host if MAGE.db_restore_host else "" }}
  db_restore_user: {{ MAGE.db_restore_user if MAGE.db_restore_user else "" }}
  db_restore_pass: {{ MAGE.db_restore_pass if MAGE.db_restore_pass else "" }}
  db_restore_db: {{ MAGE.db_restore_db if MAGE.db_restore_db else "" }}

