# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}

#sed -i 's/.*#salt-set REMOVE.*//' /etc/profile

clear-caches:
  cmd.run:
    - name: rm -rf ./var/cache/* ./var/session/* ./var/report/* ./var/locks/* ./var/log/* ./app/code/core/Zend/Cache/* ./media/css/* ./media/js/* 
    - user: root
    - cwd: {{ web_root }}

clear-sampledata-files:
  cmd.run:
    - name: rm -rf ./WSUMAGE-sampledata-master/ ./sample-data.sql ./sample-data-files/ ./staging
    - user: root
    - cwd: {{ web_root }}

clear-sample-files:
  cmd.run:
    - name: rm -rf index.php.sample .htaccess .htaccess.sample php.ini.sample LICENSE.txt STATUS.txt LICENSE.html LICENSE_AFL.txt  RELEASE_NOTES.txt
    - user: root
    - cwd: {{ web_root }}

clear-random-files:
  cmd.run:
    - name: rm -rf ./test.php && chmod -R u+w tmp?*.sh && rm -rf tmp?*.sh
    - user: root
    - onlyif: -f tmp?*
    - cwd: {{ web_root }}
    
#this is really just to bandaid another issues being worked on
finalrun-restart-nginx-{{ saltenv }}:
  cmd.run:
    - name: service nginx restart
    - user: root
    - cwd: /
    - require:
      - service: nginx-{{ saltenv }}