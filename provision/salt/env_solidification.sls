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


