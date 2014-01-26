# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 
{%- set stage_root = "salt://stage/" + env + "/" %}

download-sampledata:
  cmd.run:
    - name: modgit add -b master sampledata https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git
    - cwd: {{ web_root }}
    - user: root
    - unless: modgit ls 2>&1 | grep -qi "sampledata"
    - require:
      - service: mysqld-{{ env }}


install-sample-date:
  cmd.run:
    - name: mysql -h {{ magento['db_host'] }} -u {{ magento['db_user'] }} -p{{ magento['db_pass'] }} {{ magento['db_name'] }} < sample-data.sql
    - cwd: {{ web_root }}
    - onlyif: [ -f sample-data.sql ]
    - require:
      - cmd: download-sampledata

#clean-sample-date:
#  cmd.run:
#    - name: rm -rf WSUMAGE-sampledata-master/ sample-data.sql /sample-data-files
#    - cwd: {{ web_root }}
#    - user: root
#    - require:
#      - cmd: install-sample-date