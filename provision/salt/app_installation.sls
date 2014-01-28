# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 
{%- set stage_root = "salt://stage/vagrant/" %}

    
PEAR-registry:
  cmd.run:
    - name: ./mage mage-setup .
    - cwd: {{ web_root }}
    - require:
      - git: magento
      
set-mage-ext-pref:
  cmd.run:
    - name: ./mage install magento-core Mage_All_Latest
    - cwd: {{ web_root }}
    - require:
      - git: magento
      
magneto-install:
  cmd.run:
    - name: php -f install.php -- --license_agreement_accepted yes --locale {{ magento['locale'] }} --timezone {{ magento['timezone'] }} --default_currency {{ magento['default_currency'] }}  --db_host "{{ magento['db_host'] }}" --db_name "{{ magento['db_name'] }}" --db_user "{{ magento['db_user'] }}" --db_pass "{{ magento['db_pass'] }}" --url {{ magento['url'] }} --use_rewrites {{ magento['use_rewrites'] }} --skip_url_validation {{ magento['skip_url_validation'] }} --use_secure {{ magento['use_secure'] }} --secure_base_url {{ magento['secure_base_url'] }} --use_secure_admin {{ magento['use_secure_admin'] }} --admin_firstname "{{ magento['admin_firstname'] }}" --admin_lastname "{{ magento['admin_lastname'] }}" --admin_email "{{ magento['admin_email'] }}" --admin_username "{{ magento['admin_username'] }}" --admin_password "{{ magento['admin_password'] }}"
    - unless: php -r 'require "app/Mage.php";$app = Mage::app("default"); $installer = Mage::getSingleton("install/installer_console");  $installer->init($app); if (Mage::isInstalled()) { print("already installed"); }' 2>&1 | grep -qi 'already installed'
    - user: root
    - cwd: {{ web_root }}
    - require:
      - git: magento
      - service: mysqld-{{ env }}
      - service: php-{{ env }}


#./mage config-set preferred_state alpha
#./mage clear-cache
#./mage sync

#echo "importing WSU favicon"
#wget -q http://images.wsu.edu/favicon.ico -O favicon.ico

{{ web_root }}/staging:
  cmd.run:
    - name: mkdir {{ web_root }}staging | cp /var/www/{{ project['target'] }}/provision/salt/stage/vagrant/* {{ web_root }}staging
    - user: root

#this needs to be done in a better way
run-patchs-2619:
  cmd.run:
    - name: patch -p0 < {{ web_root }}staging/patches/PATCH_SUPEE-2619_EE_1.13.1.0_v1.patch
    - user: root
    
run-patchs-2747:
  cmd.run:
    - name: patch -p0 < {{ web_root }}staging/patches/PATCH_SUPEE-2747_EE_1.13.1.0_v1.patch
    - user: root




