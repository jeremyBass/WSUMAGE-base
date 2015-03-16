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
    - name: rm -rf ./var/cache/* ./var/session/* ./var/log/* ./app/code/core/Zend/Cache/* ./media/css/* ./media/js/* 
    - user: root
    - cwd: {{ web_root }}

#clear-staging-files:
#  cmd.run:
#    - name: rm -rf ./staging
#    - user: root
#    - cwd: {{ web_root }}

clear-sample-files:
  cmd.run:
    - name: rm -rf index.php.sample .htaccess .htaccess.sample php.ini.sample LICENSE.txt STATUS.txt LICENSE.html LICENSE_AFL.txt  RELEASE_NOTES.txt LICENSE test.php README README.* *.pdf .travis.yml
    - user: root
    - cwd: {{ web_root }}

clear-random-files:
  cmd.run:
    - name: chmod -R u+w tmp?*.sh && rm -rf tmp?*.sh
    - user: root
    - onlyif: test -f tmp?*
    - cwd: {{ web_root }}

clear-fresh-install:
  cmd.run:
    - name: unset MagentoInstalled_Fresh
    - user: root
    - onlyif: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"

#this is really just to bandaid another issues being worked on
finalrun-restart-nginx-{{ saltenv }}:
  cmd.run:
    - name: service nginx restart
    - user: root
    - cwd: /
    - require:
      - service: nginx-{{ saltenv }}