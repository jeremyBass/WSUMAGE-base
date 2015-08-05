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
{% if vars.update({'ip': salt['cmd.run']('(ifconfig eth1 2>/dev/null || ifconfig eth0 2>/dev/null) | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}

## note it should be that only on need does this get run
## question what the need is, then test for it


## if the repo of sample data exists
reload-sampledata:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: gitploy re -q -b 1.9.1.0 sampledata
    - cwd: {{ web_root }}
    - user: root
    - require:
      - service: mysqld-{{ saltenv }}
##else load it 
load-sampledata:
  cmd.run:
    - unless: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: gitploy ls 2>&1 | grep -qi "MAGE" && gitploy -q -b 1.9.1.0 sampledata https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git
    - cwd: {{ web_root }}
    - user: root
    - require:
      - service: mysqld-{{ saltenv }}
##end 

##install sample data
install-sample-date:
  cmd.run:
    - onlyif: test -f sample-data.sql
    - unless: test x"$mage_sameple_data" = x
    - name: 'mysql -h {{ database['host'] }} -u {{ database['user'] }} -p{{ database['pass'] }} {{ database['name'] }} < sample-data.sql && mysql -h {{ database['host'] }} -u {{ database['user'] }} -p{{ database['pass'] }} {{ database['name'] }} -e "create database somedb" && echo "export mage_sameple_data=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/environment'
    - cwd: {{ web_root }}

clear-sampledata:
  cmd.run:
    - name: rm -rf ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/
    - user: root
    - cwd: {{ web_root }}