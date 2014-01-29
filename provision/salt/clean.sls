# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + env + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}


clear-caches:
  cmd.run:
    - name: rm -rf ./var/cache/* ./var/session/* ./var/report/* ./var/locks/* ./var/log/* ./app/code/core/Zend/Cache/* ./media/css/* ./media/js/* 
    - user: root
    - cwd: {{ web_root }}

clear-sampledata-files:
  cmd.run:
    - name: rm -rf ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/
    - user: root
    - cwd: {{ web_root }}

clear-sample-files:
  cmd.run:
    - name: rm -rf index.php.sample .htaccess.sample php.ini.sample LICENSE.txt STATUS.txt LICENSE.html LICENSE_AFL.txt  RELEASE_NOTES.txt
    - user: root
    - cwd: {{ web_root }}
