# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}

reload-sampledata:
  cmd.run:
    - name: gitploy re -q -b 1.9.1.0 sampledata
    - cwd: {{ web_root }}
    - user: root
    - unless: gitploy ls 2>&1 | grep -qi "sampledata"
    - require:
      - service: mysqld-{{ saltenv }}
  
load-sampledata:
  cmd.run:
    - name: gitploy ls 2>&1 | grep -qi "MAGE" && gitploy -q -b 1.9.1.0 sampledata https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git
    - cwd: {{ web_root }}
    - user: root
    - unless: gitploy ls 2>&1 | grep -qi "sampledata"
    - require:
      - service: mysqld-{{ saltenv }}

install-sample-date:
  cmd.run:
    - name: 'mysql -h {{ database['host'] }} -u {{ database['user'] }} -p{{ database['pass'] }} {{ database['name'] }} < sample-data.sql && echo "export SAMPLEMAGE=True {% raw %}#salt-set REMOVE{% endraw %}-{{ ext_key }}" >> /etc/profile'
    - cwd: {{ web_root }}
    - onlyif: test -f sample-data.sql
    - unless:  test x"$SAMPLEMAGE" = x
    - require:
      - cmd: download-sampledata

uninstall-clear-sampledata:
  cmd.run:
    - name: rm -rf ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/
    - user: root
    - cwd: {{ web_root }}

clear-sampledata:
  cmd.run:
    - name: rm -rf ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/
    - user: root
    - cwd: {{ web_root }}