<?php
{% if isLocal %}
    define('BASEURL', 'mage.dev');
{% else %}
    define('BASEURL', 'wsu.edu');
{%- endif %}




