# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{#%- set stage_root = "salt://stage/vagrant/" %#}
{%- set stage_root = "/var/app/" + saltenv + "/provision/salt/stage/vagrant/" %}
{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': salt['cmd.run']('ifconfig eth1 | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}



###############################################
# staging
###############################################

{%- set web_stage_root = web_root + "staging/" %}
{{ web_root }}staging/:
  file.directory:
    - name: {{ web_root }}staging/
    - user: www-data
    - group: www-data

{{ web_stage_root }}sql:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}sql && cp {{ stage_root }}sql/* {{ web_stage_root }}sql
    - user: root
    - unless: cd {{ web_stage_root }}sql
    
{{ web_stage_root }}scripts:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}scripts && cp {{ stage_root }}scripts/* {{ web_stage_root }}scripts
    - user: root
    - unless: cd {{ web_stage_root }}scripts

{{ web_stage_root }}patches:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}patches && cp {{ stage_root }}patches/* {{ web_stage_root }}patches
    - user: root
    - unless: cd {{ web_stage_root }}patches

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
    - source: {{ stage_root }}scripts/index.php
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
{{ web_root }}staging/scripts/install-config.php:
  file.managed:
    - source: {{ stage_root }}scripts/install-config.php
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
    - name: php staging/scripts/post-install-process.php
    - cwd: {{ web_root }}
    - user: root
    - unless: test x"$MagentoInstalled_Fresh" = x
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install

###############################################
# setup services for mage
###############################################
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

setup-magento-cron:
  cron.present:
    - name: php {{ web_root }}cron.php
    - user: root
    - minute: '*/5'

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





