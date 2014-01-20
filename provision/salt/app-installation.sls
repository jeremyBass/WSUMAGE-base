# set up data first
###########################################################
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}

PEAR-registry:
  cmd.run:
    - name: ./mage mage-setup .

set-mage-ext-pref:
  cmd.run:
    - name: ./mage install magento-core Mage_All_Latest

magneto-install:
  cmd.run:
    - name: php -f install.php -- --license_agreement_accepted yes --locale en_US --timezone America/Los_Angeles --default_currency USD  --db_host localhost --db_name wsumage_network --db_user magevag --db_pass magevag --url store.mage.dev --use_rewrites yes --skip_url_validation yes --use_secure no --secure_base_url "" --use_secure_admin no --admin_firstname "Jeremy" --admin_lastname "Bass" --admin_email "jeremy.bass@wsu.edu" --admin_username "jeremy.bass" --admin_password "demo2013"



# Start the extension intsalls
{% for ext_key, ext_val in magento_extensions.iteritems() %}
base-ext-{{ ext_key }}:
  cmd.run:
    - name: modgit add {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ ext_key }} https://github.com/{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git
    - cwd: /var/www/store.wsu.edu/html/
    - unless: ! modgit ls 2>/dev/null | grep -qi "{{ ext_key }}"
{% endfor %}

/var/www/store.wsu.edu/html/mage-{{ magento_version }}.txt:
  file.managed:
    - user: www-data
    - group: www-data








