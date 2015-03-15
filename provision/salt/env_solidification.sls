# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}

{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': salt['cmd.run']('ifconfig eth1 | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}


# trun things back on and removed any notices
##########################################################


###############################################
# setup services for mage
###############################################

{% if 'webcaching' in grains.get('roles') %}
# Turn on all caches
memcached-start:
  cmd.run:
    - name: service memcached start
    - cwd: /
{% endif %}

{% if isLocal %}
   # only items that needs to be truned back on for only local devleopment.
   # xdebug is the thought
{% else %}
   # anything that needs to be truned back on but only the production servers
   # trun off store mantance notices
{%- endif %}

final-restart-nginx-{{ saltenv }}:
  cmd.run:
    - name: service nginx restart
    - user: root
    - cwd: /
    - require:
      - service: nginx-{{ saltenv }}


reset-magento:
  cmd.run:
    - name: rm -rf {{ web_root }}var/cache/* | rm -rf {{ web_root }}media/js/* | rm -rf {{ web_root }}media/css/*
    - cwd: {{ web_root }}
    - user: root
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install


reindex-magento:
  cmd.run:
    - name: php -f indexer.php reindexall | php "{{ web_root }}index.php" 2>/dev/null
    - cwd: {{ web_root }}/shell
    - user: root
    - unless: test x"$MagentoInstalled_Fresh" = x
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install






