# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set stores = pillar.get('stores',{}) %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set app_root = "/var/app/" + saltenv + "/" %}
{%- set web_root = app_root + "html/" %}
{#%- set stage_root = "salt://config/mage/" %#}
{%- set stage_root = app_root + "provision/salt/config/mage/" %}
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
    
{{ web_stage_root }}states:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}states && cp {{ app_root }}states/* {{ web_stage_root }}states
    - user: root
    - unless: cd {{ web_stage_root }}states

{{ web_stage_root }}settings:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}settings && cp {{ stage_root }}settings/* {{ web_stage_root }}settings
    - user: root
    - unless: cd {{ web_stage_root }}settings



# retrive store base states
##############################################

{{ app_root }}states:
  cmd.run:
    - name: mkdir -p {{ app_root }}states
    - user: root
    - unless: cd {{ app_root }}states

{% for ext_key, ext_val in stores|dictsort %}

{%- set track_name = ext_val['track_name'] -%}

{{ app_root }}states/{{ ext_key }}:
  cmd.run:
    - name: mkdir -p {{ app_root }}states/{{ ext_key }}
    - user: root
    - unless: cd {{ app_root }}states/{{ ext_key }}

store-{{ ext_key }}-update:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "{{ track_name }}"
    - name: 'gitploy up -q {% if ext_val['exclude'] %} -e {{ ext_val['exclude'] }} {%- endif %} -p "{{ app_root }}states/{{ ext_key }}" {% if ext_val['tag'] %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] %} -b {{ ext_val['branch'] }} {%- endif %} {{ track_name }}'
    - cwd: {{ app_root }}
    - user: root

store-{{ ext_key }}-install:
  cmd.run:
    - unless: gitploy ls 2>&1 | grep -qi "{{ track_name }}"
    - name: 'gitploy -q {% if ext_val['exclude'] %} -e {{ ext_val['exclude'] }} {%- endif %} -p "{{ app_root }}states" {% if ext_val['tag'] %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] %} -b {{ ext_val['branch'] }} {%- endif %} {{ track_name }} {% if ext_val['protocol'] %}{{ ext_val['protocol'] }}{%- else %}https://github.com/{%- endif %}{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git && echo "export ADDED{{ track_name|replace("-","") }}=True {% raw %}#salt-set REMOVE{% endraw %}-{{ ext_key }}" >> /etc/environment'
    - cwd: {{ app_root }}
    - user: root

{{ web_stage_root }}states/{{ ext_key }}:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}states/{{ ext_key }} && cp {{ app_root }}states/{{ ext_key }}/* {{ web_stage_root }}states/{{ ext_key }}
    - user: root
    - unless: cd {{ web_stage_root }}states/{{ ext_key }}

{{ web_stage_root }}states/{{ ext_key }}/settings:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}states/{{ ext_key }}/settings && cp {{ app_root }}states/{{ ext_key }}/settings/* {{ web_stage_root }}states/{{ ext_key }}/settings
    - user: root
    - unless: cd {{ web_stage_root }}states/{{ ext_key }}/settings


{% endfor %}







###############################################
# ensure proper index.php
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



