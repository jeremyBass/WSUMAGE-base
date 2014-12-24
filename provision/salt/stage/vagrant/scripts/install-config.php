 /*   isLocal:  vars.isLocal 
      magento:  magento 
      database:  database 
      project:  project 
      saltenv:  saltenv 
*/

<?php
define('BASEURL', {{ magento.baseurl|lower }});
define('SAMPLE_STORE', {{ magento.sample_stores|lower }} );



