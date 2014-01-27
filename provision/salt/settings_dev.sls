# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 
{%- set stage_root = "salt://stage/vagrant/" %} 


# move the apps nginx rules to the site-enabled
{{ web_root }}index.php:
  file.managed:
    - source: {{ stage_root }}index.php
    - user: root
    - group: root
    - mode: 644
    - replace: True

post-install-settings:
  cmd.run:
    - name: php staging/install-post.php
    - cwd: {{ web_root }}
    - require:
      - git: magento
      - service: mysqld-{{ env }}
      - service: php-{{ env }}
      - cmd: magneto-install


final-restart-nginx-{{ env }}:
  cmd.run:
    - name: service nginx restart
    - user: root
    - cwd: /
    - require:
      - service: nginx-{{ env }}

reset-magento:
  cmd.run:
    - name: rm -rf {{ web_root }}var/cache/* | php "{{ web_root }}index.php" 2>/dev/null
    - cwd: {{ web_root }}
    - user: root
    - require:
      - git: magento
      - service: mysqld-{{ env }}
      - service: php-{{ env }}
      - cmd: magneto-install
      - cmd: base-ext-{{ ext_key }}

