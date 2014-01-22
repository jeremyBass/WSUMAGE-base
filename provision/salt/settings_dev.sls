# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 
{%- set stage_root = "/var/www/" + project['target'] + "/stage/vagrant/" %} 


{{ web_root }}/staging:
  cmd.run:
    - name: cp {{ stage_root }} {{ web_root }}staging
    - user: root


post-install-settings:
  cmd.run:
    - name: php staging/install-post.php
    - cwd: {{ web_root }}
    - require:
      - git: magento
      - service: mysqld-{{ env }}
      - service: php-{{ env }}
      - cmd: magneto-install
