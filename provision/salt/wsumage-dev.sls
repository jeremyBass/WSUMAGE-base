# check for needed services and installs
############################################################

git:
  pkg.installed:
    - name: git

php-fpm:
  service:
    - running

mysqld:
  service:
    - running

# Setup the MySQL requirements for WSUMAGE-base
#
# user: mage
# pass: mage
# db:   wsumage_store.wsu.edu
wsuwp-db:
  mysql_user.present:
    - name: mage
    - password: mage
    - host: localhost
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysqld
  mysql_database.present:
    - name: wsumage_store.wsu.edu
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysqld
  mysql_grants.present:
    - grant: all privileges
    - database: wsuwp.*
    - user: wp
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysqld

# The install is going to run, there is no caching needed yet.  Stop
memcached-stopped:
  cmd.run:
    - name: service memcached stop
    - cwd: /
    

/var/www/wsuwp-platform:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664
    - recurse:
        - user
        - group


#Modgit for magento modules
modgit:
  cmd.run:
    - name: curl https://raw.github.com/jeremyBass/modgit/master/modgit > /var/www/store.wsu.edu/stage/modgit
    - unless: cd /var/www/store.wsu.edu/stage/modgit
    - require_in:
      - file: exe-modgit
      - file: link-modgit

exe-modgit:
  file.managed:
    - name: /var/www/store.wsu.edu/stage/modgit
    - user: www-data
    - group: www-data
    - mode: 744
    
link-modgit:
  file.symlink:
    - name: /usr/local/bin/modgit
    - target: /var/www/store.wsu.edu/stage/modgit
    - force: True
    - makedirs: True

#magento base
magento:
  git.latest:
    - name: git://github.com/jeremyBass/magento-mirror.git
    - rev: 1.8.1.0
    - target: /var/www/store.wsu.edu/html/
    - force: True
    - unless: cd /var/www/store.wsu.edu/html/app/code/core/Mage/Admin/data/admin_setup
    

