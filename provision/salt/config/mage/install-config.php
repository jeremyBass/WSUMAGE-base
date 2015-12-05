<?php
define('BASEURL', '{{ magento['base-url']|lower }}');
define('SAMPLE_STORE', '{{ magento['sample_stores']|lower }}');
define('SETTINGS_INSTALLED', '{{ settings_installed }}');
define('OVERLOAD_SETTINGS', '{{ magento['overload_settings']|lower }}'); 


define('UNSECURE_BASE_URL', 'http://{{ magento['url']|lower }}/');
define('SECURE_BASE_URL', 'https://{{ magento['url']|lower }}/');
define('ADMIN_URL', 'http://{{ magento['url']|lower }}/{{ magento['backend-frontname'] }}/');

$_GLOBAL['STORES'] = array(
{% for ext_key, ext_val in stores|dictsort %}
'{{ ext_key }}',
{% endfor %}
);
