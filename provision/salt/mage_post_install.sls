# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}

{%- set stores_objs = pillar.get('stores_objs',{}) %}
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

{{ app_root }}states:
  file.directory:
    - name: {{ app_root }}states
    - user: www-data
    - group: www-data

{{ web_stage_root }}states/:
  file.directory:
    - name: {{ web_stage_root }}states/
    - user: www-data
    - group: www-data

# retrive store base states
##############################################

{% for store,repo_parts in stores_objs.iteritems() %}

{%- set track_name = repo_part['track_name'] -%}

"{{ app_root }}states/{{ store }}":
  cmd.run:
    - name: mkdir -p {{ app_root }}states/{{ store }}
    - user: root
    - unless: cd {{ app_root }}states/{{ store }}

"store-{{ store }}-update":
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "{{ track_name }}"
    - name: 'gitploy up -q {% if repo_parts['exclude'] %} -e {{ repo_parts['exclude'] }} {%- endif %} -p "{{ app_root }}states/{{ store }}" {% if repo_parts['tag'] %} -t {{ repo_parts['tag'] }} {%- endif %} {% if repo_parts['branch'] %} -b {{ repo_parts['branch'] }} {%- endif %} {{ track_name }}'
    - cwd: {{ app_root }}
    - user: root

"store-{{ store }}-install":
  cmd.run:
    - unless: gitploy ls 2>&1 | grep -qi "{{ track_name }}"
    - name: 'gitploy -q {% if repo_parts['exclude'] %} -e {{ repo_parts['exclude'] }} {%- endif %} -p "{{ app_root }}states" {% if repo_parts['tag'] %} -t {{ repo_parts['tag'] }} {%- endif %} {% if repo_parts['branch'] %} -b {{ repo_parts['branch'] }} {%- endif %} {{ track_name }} {% if repo_parts['protocol'] %}{{ repo_parts['protocol'] }}{%- else %}https://github.com/{%- endif %}{{ repo_parts['repo_owner'] }}/{{ repo_parts['name'] }}.git && echo "export ADDED{{ track_name|replace("-","") }}=True {% raw %}#salt-set REMOVE{% endraw %}-{{ store }}" >> /etc/environment'
    - cwd: {{ app_root }}
    - user: root

"{{ web_stage_root }}states/{{ store }}":
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}states/{{ store }} && cp {{ app_root }}states/{{ store }}/* {{ web_stage_root }}states/{{ store }}
    - user: root
    - unless: cd {{ web_stage_root }}states/{{ store }}

"{{ web_stage_root }}states/{{ store }}/settings":
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}states/{{ store }}/settings && cp {{ app_root }}states/{{ store }}/settings/* {{ web_stage_root }}states/{{ store }}/settings
    - user: root
    - unless: cd {{ web_stage_root }}states/{{ store }}/settings


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
      stores: {{ stores_objs }}

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



