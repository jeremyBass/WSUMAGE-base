 /*   isLocal:  vars.isLocal 
      magento:  magento 
      database:  database 
      project:  project 
      saltenv:  saltenv 
*/

<?php
{% if isLocal %}
    define('BASEURL', 'mage.dev');
{% else %}
    define('BASEURL', 'wsu.edu');
{%- endif %}
define('SAMPLE_STORE', {{ magento.sample_stores|lower }} );



