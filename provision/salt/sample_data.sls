# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + env + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}


download-sampledata:
  cmd.run:
    - name: gitploy -b master sampledata https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git
    - cwd: {{ web_root }}
    - user: root
    - unless: test -f sample-data.sql
    - require:
      - service: mysqld-{{ env }}


install-sample-date:
  cmd.run:
    - name: mysql -h {{ database['host'] }} -u {{ database['user'] }} -p{{ database['pass'] }} {{ database['name'] }} < sample-data.sql
    - cwd: {{ web_root }}
    - onlyif: test -f sample-data.sql
    #- unless:  test x"$MagentoFreshInstalled" = x
    - require:
      - cmd: download-sampledata
