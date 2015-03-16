<?php
define('BASEURL', '{{ magento['baseurl']|lower }}');
define('SAMPLE_STORE', '{{ magento['sample_stores']|lower }}');


define('UNSECURE_BASE_URL', 'http://{{ magento['url']|lower }}/');
define('SECURE_BASE_URL', 'https://{{ magento['url']|lower }}/');
define('ADMIN_URL', 'http://{{ magento['admin_url']|lower }}/');



