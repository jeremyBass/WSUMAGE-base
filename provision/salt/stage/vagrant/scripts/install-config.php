<?php
define('BASEURL', '{{ magento['baseurl']|lower }}');
define('SAMPLE_STORE', '{{ magento['sample_stores']|lower }}');

define('ADMIN_URL', 'http://store.admin.{{ magento['baseurl']|lower }}/');
define('UNSECURE_BASE_URL', 'http://store.admin.{{ magento['baseurl']|lower }}/');
define('SECURE_BASE_URL', 'http://store.admin.{{ magento['baseurl']|lower }}/');




