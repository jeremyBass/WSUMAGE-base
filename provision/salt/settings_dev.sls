# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}


# move the apps nginx rules to the site-enabled
{{ web_root }}index.php:
  file.managed:
    - source: {{ stage_root }}scripts/index.php
    - user: www-data
    - group: www-data
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}

post-install-settings:
  cmd.run:
    - name: php staging/scripts/install-post.php
    - cwd: {{ web_root }}
    - user: root
    - unless: test x"$MagentoFreshInstalled" = x
    - require:
      - git: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install


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
      - git: magento
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
    - unless: test x"$MagentoFreshInstalled" = x
    - require:
      - git: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install