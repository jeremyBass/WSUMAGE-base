# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 
{%- set stage_root = "salt://stage/vagrant/" %}


clear-caches:
  cmd.run:
    - name: rm -rf ./var/cache/* ./var/session/* ./var/report/* ./var/locks/* ./var/log/* ./app/code/core/Zend/Cache/* ./media/css/* ./media/js/* ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/
    - user: root
    - cwd: {{ web_root }}
 
#rm -rf index.php.sample .htaccess.sample php.ini.sample LICENSE.txt
#rm -rf STATUS.txt LICENSE.html LICENSE_AFL.txt  RELEASE_NOTES.txt
 
 

        