# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 


magneto-install:
  cmd.run:
    - name: php -f install.php -- --license_agreement_accepted yes --locale {{ magento['locale'] }} --timezone {{ magento['timezone'] }} --default_currency {{ magento['default_currency'] }}  --db_host "{{ magento['db_host'] }}" --db_name "{{ magento['db_name'] }}" --db_user "{{ magento['db_user'] }}" --db_pass "{{ magento['db_pass'] }}" --url {{ magento['url'] }} --use_rewrites {{ magento['use_rewrites'] }} --skip_url_validation {{ magento['skip_url_validation'] }} --use_secure {{ magento['use_secure'] }} --secure_base_url {{ magento['secure_base_url'] }} --use_secure_admin {{ magento['use_secure_admin'] }} --admin_firstname "{{ magento['admin_firstname'] }}" --admin_lastname "{{ magento['admin_lastname'] }}" --admin_email "{{ magento['admin_email'] }}" --admin_username "{{ magento['admin_username'] }}" --admin_password "{{ magento['admin_password'] }}"
    - user: root
    - cwd: {{ web_root }}
    - unless: ! php -r "require 'app/Mage.php';try {$app = Mage::app('default');$installer = Mage::getSingleton('install/installer_console');$installer->init($app);} catch (Exception $e) {Mage::printException($e);}" 2>/dev/null | awk "/already installed/"
    - require:
      - service: mysqld-{{ env }}







