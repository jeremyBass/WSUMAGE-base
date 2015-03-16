# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set app_root = "/var/app/" + saltenv + "/" %}
{%- set web_root = app_root "/html/" %}
{#%- set stage_root = "salt://config/mage/" %#}
{%- set stage_root = "/var/app/" + saltenv + "/provision/salt/config/mage/" %}
{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': salt['cmd.run']('ifconfig eth1 | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}



###############################################
# staging
###############################################

{%- set web_stage_root = web_root + "staging/" %}
{{ web_root }}staging/:
  file.directory:
    - name: {{ web_stage_root }}
    - user: www-data
    - group: www-data
    
{{ web_stage_root }}stores:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}stores && cp {{ stage_root }}stores/* {{ web_stage_root }}stores
    - user: root
    - unless: cd {{ web_stage_root }}scripts

{{ web_stage_root }}settings:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}settings && cp {{ stage_root }}settings/* {{ web_stage_root }}settings
    - user: root
    - unless: cd {{ web_stage_root }}settings


###############################################
# sample data
###############################################
# move the apps nginx rules to the site-enabled
{{ web_root }}index.php:
  file.managed:
    - source: {{ stage_root }}index.php
    - user: www-data
    - group: www-data
    - replace: True
    - template: jinja
    - context:
      isLocal: {{ vars.isLocal }}
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}

###############################################
# start a setting stage for each store
###############################################
# to define the stores
{{ web_stage_root }}install-config.php:
  file.managed:
    - source: {{ stage_root }}install-config.php
    - user: www-data
    - group: www-data
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      isLocal: {{ vars.isLocal }}
      saltenv: {{ saltenv }}
      web_root: {{ web_root }}

# we now will start to call out for the store state files for the dev/prod setup

# settings to stores
post-install-settings:
  cmd.run:
    - name: php {{ web_stage_root }}post-install-processing.php
    - cwd: {{ web_root }}
    - user: root
    - unless: test x"$MagentoInstalled_Fresh" = x
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install

# install any cronjob needed
setup-magento-cron:
  cron.present:
    - name: php {{ web_root }}cron.php
    - user: root
    - minute: '*/5'



