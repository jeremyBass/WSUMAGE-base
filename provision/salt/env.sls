# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 



# Create service checks
###########################################################
mysqld-{{ env }}:
  service.running:
    - name: mysqld

php-{{ env }}:
  service.running:
    - name: php-fpm

nginx-{{ env }}:
  service.running:
    - name: nginx




# Setup the MySQL requirements for WSUMAGE-base
###########################################################
db-{{ magento['db_name'] }}:
  mysql_database.present:
    - name: {{ magento['db_name'] }}
    - require:
      - service: mysqld-{{ env }}

db_users-{{ magento['db_user'] }}:
  mysql_user.present:
    - name: {{ magento['db_user'] }}
    - password: {{ magento['db_pass'] }}
    - host: {{ magento['db_host'] }}
    - require:
      - service: mysqld-{{ env }}
      
db_grant-{{ magento['db_name'] }}:
  mysql_grants.present:
    - grant: all privileges
    - host: {{ magento['db_host'] }}
    - database: {{ magento['db_name'] }}.*
    - user: {{ magento['db_user'] }}
    - require:
      - service: mysqld-{{ env }}

# The install is going to run, there is no caching needed yet.
memcached-stopped:
  cmd.run:
    - name: service memcached stop
    - cwd: /

# move the apps nginx rules to the site-enabled
/etc/nginx/sites-enabled/store.mage.dev.conf:
  file.managed:
    - source: salt://config/nginx/store.mage.dev.conf
    - user: root
    - group: root
    - mode: 644

# move the apps nginx rules to the site-enabled
{{ web_root }}maps/nginx-mapping.conf:
  file.managed:
    - source: salt://config/nginx/maps/nginx-mapping.conf
    - user: www-data
    - group: www-data
    - mode: 664

restart-nginx-{{ env }}:
  cmd.run:
    - name: sudo service nginx restart
    - cwd: /
    - require:
      - service: nginx-{{ env }}

/var/www/store.wsu.edu/html:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664

#magento base
magento:
  git.latest:
    - name: git://github.com/jeremyBass/magento-mirror.git
    - rev: 1.8.1.0
    - target: {{ web_root }}
    - force: True
    - unless: cd {{ web_root }}app/code/core/Mage/Admin/data/admin_setup


#Modgit for magento modules
modgit:
  cmd.run:
    - name: curl https://raw.github.com/jeremyBass/modgit/master/modgit > /home/vagrant/modgit
    - cwd: /home/vagrant/
    - user: root
    - unless: which modgit
    - require_in:
      - file: exe-modgit
      - file: link-modgit

exe-modgit:
  file.managed:
    - name: /home/vagrant/modgit
    - user: root
    - group: root
    - mode: 744
    
link-modgit:
  file.symlink:
    - name: /usr/local/bin/modgit
    - target: /home/vagrant/modgit
    - force: True
    - makedirs: True


#start modgit tracking
init_modgit:
  cmd.run:
    - name: modgit init
    - cwd: {{ web_root }}
    - unless: test -d {{ web_root }}.modgit
    - user: root

#do a dry run test of modgit
modgit_dryrun:
  cmd.run:
    - name: modgit add -n Storeutilities https://github.com/washingtonstateuniversity/WSUMAGE-store-utilities.git 2>/dev/null | grep -qi "error" && echo "name=modgit_dryrun result=False changed=False comment=failed" || echo "name=modgit_dryrun  result=True changed=True comment=passed"
    - cwd: {{ web_root }}
    - user: root
    - stateful: True
    - require:
      - cmd: init_modgit

#add a database explorer
install-adminer:
  cmd.run:
    - name: wget "http://www.adminer.org/latest-mysql-en.php"  -O adminer.php | wget "https://raw.github.com/vrana/adminer/master/designs/haeckel/adminer.css"  -O adminer.css
    - cwd: {{ web_root }}
    - unless: -f {{ web_root }}adminer.php



