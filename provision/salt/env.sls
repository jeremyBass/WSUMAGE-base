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
{% for ip in salt['grains.get']('ipv4') if ip.startswith('10.255.255') -%}
    {% if vars.update({'isLocal': True}) %} {% endif %}
{%- endfor %}

# Create service checks
###########################################################
mysqld-{{ saltenv }}:
  service.running:
    - name: mysqld

php-{{ saltenv }}:
  service.running:
    - name: php-fpm

nginx-{{ saltenv }}:
  service.running:
    - name: nginx


# Turn off all caches
memcached-stopped:
  cmd.run:
    - name: service memcached stop
    - cwd: /



# Setup the MySQL requirements for WSUMAGE-base
###########################################################
magedb-{{ database['name'] }}:
  mysql_database.present:
    - name: {{ database['name'] }}
    - require:
      - service: mysqld-{{ saltenv }}

magedb_users-{{ database['user'] }}:
  mysql_user.present:
    - name: {{ database['user'] }}
    - password: {{ database['pass'] }}
    - host: {{ database['host'] }}
    - require:
      - service: mysqld-{{ saltenv }}
      
magedb_grant-{{ database['name'] }}:
  mysql_grants.present:
    - grant: all
    - host: {{ database['host'] }}
    - database: {{ database['name'] }}.*
    - user: {{ database['user'] }}
    - require:
      - service: mysqld-{{ saltenv }}






{{ web_root }}:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664


#Modgit for magento modules
gitploy:
  cmd.run:
    - name: curl https://raw.github.com/jeremyBass/gitploy/master/gitploy | sudo sh -s -- install
    - cwd: /
    - user: root
    - unless: which gitploy

#start modgit tracking
init_gitploy:
  cmd.run:
    - name: gitploy init
    - cwd: {{ web_root }}
    - unless: test -d {{ web_root }}.gitploy
    - user: root


#magento base
#magento:
#  git.latest:
#    - name: git://github.com/washingtonstateuniversity/magento-mirror.git
#    - rev: 1.8.1.0
#    - target: {{ web_root }}
#    - force: True
#    - unless: cd {{ web_root }}app/code/core/Mage/Admin/data/admin_setup


magento:
  cmd.run:
    - name: 'gitploy -q -t 1.8.1.0 MAGE https://github.com/washingtonstateuniversity/magento-mirror.git && echo "export ADDEDMAGE=True {% raw %}#salt-set REMOVE{% endraw %}-MAGE" >> /etc/profile'
    - cwd: {{ web_root }}
    - user: root
    - unless: modgit ls 2>&1 | grep -qi "MAGE"
    - require:
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}


# move the apps nginx rules to the site-enabled
/etc/nginx/sites-enabled/store.mage.dev.conf:
  file.managed:
    - source: salt://config/nginx/store.mage.dev.conf
    - user: root
    - group: root
    
{{ web_root }}maps/:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664

# move the apps nginx rules to the site-enabled
{{ web_root }}maps/nginx-mapping.conf:
  file.managed:
    - source: salt://config/nginx/maps/nginx-mapping.conf
    - user: www-data
    - group: www-data
    - mode: 744

restart-nginx-{{ saltenv }}:
  cmd.run:
    - name: service nginx restart
    - user: root
    - cwd: /
    - require:
      - service: nginx-{{ saltenv }}




#do a dry run test of modgit
gitploy_dryrun:
  cmd.run:
    - name: gitploy -d Storeutilities https://github.com/washingtonstateuniversity/WSUMAGE-store-utilities.git 2>/dev/null | grep -qi "error" && echo "name=gitploy_dryrun result=False changed=False comment=failed" || echo "name=gitploy_dryrun  result=True changed=True comment=passed"
    - cwd: {{ web_root }}
    - user: root
    - stateful: True
    - require:
      - cmd: init_gitploy

{% if vars.isLocal %}
#add a database explorer
install-adminer:
  cmd.run:
    - name: wget "http://www.adminer.org/latest-mysql-en.php"  -O adminer.php | wget "https://raw.github.com/vrana/adminer/master/designs/haeckel/adminer.css"  -O --no-check-certificate adminer.css
    - cwd: {{ web_root }}
    - unless: -f {{ web_root }}adminer.php
{%- endif %}


