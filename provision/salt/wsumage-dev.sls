# Setup the MySQL requirements for WSUMAGE-base
#
# user: mage
# pass: mage
# db:   wsumage_store.wsu.edu
wsumage-db:
  mysql_user.present:
    - name: mage
    - password: mage
    - host: localhost
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysql-start
  mysql_database.present:
    - name: wsumage_store.wsu.edu
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysql-start
  mysql_grants.present:
    - grant: all privileges
    - database: wsuwp.*
    - user: wp
    #- require_in:
    #  - cmd: wsuwp-install-network
    - require:
      - service: mysql-start

# The install is going to run, there is no caching needed yet.  Stop
memcached-stopped:
  cmd.run:
    - name: service memcached stop
    - cwd: /
    

/var/www/store.wsu.edu/html:
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

#magento base
magento:
  git.latest:
    - name: git://github.com/jeremyBass/magento-mirror.git
    - rev: 1.8.1.0
    - target: /var/www/store.wsu.edu/html/
    - force: True
    - unless: cd /var/www/store.wsu.edu/html/app/code/core/Mage/Admin/data/admin_setup






