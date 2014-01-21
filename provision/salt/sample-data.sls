# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 

download-sampledata:
  cmd.run:
    - name: modgit add -b master sampledata https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git
    - cwd: {{ web_root }}
    - user: root
    - unless: ! modgit ls 2>/dev/null | grep -qi "sampledata"
    - require:
      - service: mysqld-{{ env }}



#download-sample-date:
#  file.directory:
#    - name: {{ web_root }}/sampledata
#    - user: www-data
#    - group: www-data
#  cmd.run:
#    - name: git clone --depth=1 https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git sampledata | rm -rf !$/.git | cp -af {{ web_root }}sampledata/* {{ web_root }} 
#    - cwd: {{ web_root }}/sampledata
#    - user: root
#    - require:
#      - file: download-sample-date

install-sample-date:
  cmd.run:
    - name: mysql -h {{ magento['db_host'] }} -u {{ magento['db_user'] }} -p{{ magento['db_pass'] }} {{ magento['db_name'] }} < sample-data.sql
    - cwd: {{ web_root }}
    - require:
      - file: download-sampledata

clean-sample-date:
  cmd.run:
    - name: rm -rf WSUMAGE-sampledata-master/ sample-data.sql /sample-data-files
    - cwd: {{ web_root }}
    - user: root
    - require:
      - file: install-sample-date