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

###############################################
# magneto install
###############################################    
# move the apps nginx rules to the site-enabled
{{ web_root }}mage: 
   file.managed:
    - user: root
    - group: root
    - mode: 744

PEAR-registry:
  cmd.run:
    - name: ./mage mage-setup .
    - user: root
    - cwd: {{ web_root }}
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled=True"
    - require:
      - cmd: magento
      
set-mage-ext-pref:
  cmd.run:
    - name: ./mage install magento-core Mage_All_Latest
    - user: root
    - cwd: {{ web_root }}
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled=True"
    - require:
      - cmd: magento
      
magneto-install:
  cmd.run:
    - name: 'tmp=$(php -f install.php -- --license_agreement_accepted yes --locale {{ magento['locale'] }} --timezone {{ magento['timezone'] }} --default_currency {{ magento['default_currency'] }}  --db_host "{{ database['host'] }}" --db_name "{{ database['name'] }}" --db_user "{{ database['user'] }}" --db_pass "{{ database['pass'] }}" {% if database['prefix'] is defined and database['prefix'] is not none %} --db_prefix "{{ database['prefix'] }}" {%- endif %} --url {{ magento['url'] }} --use_rewrites {{ magento['use_rewrites'] }} --skip_url_validation {{ magento['skip_url_validation'] }} --use_secure {{ magento['use_secure'] }} --secure_base_url {{ magento['secure_base_url'] }} --use_secure_admin {{ magento['use_secure_admin'] }} --admin_firstname "{{ magento['admin_firstname'] }}" --admin_lastname "{{ magento['admin_lastname'] }}" --admin_email "{{ magento['admin_email'] }}" --admin_username "{{ magento['admin_username'] }}" --admin_password "{{ magento['admin_password'] }}"  3>&1 1>&2 2>&3) && echo "export MagentoInstalled_Fresh=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/profile && echo "export MagentoInstalled=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/profile && echo $tmp'
    - unless: printenv 2>&1 | grep -qi "MagentoFreshInstalled=True"
    - user: root
    - cwd: {{ web_root }}
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}

magneto-set-connect-prefs:
  cmd.run:
    - name: ./mage config-set preferred_state alpha | ./mage clear-cache | ./mage sync
    - cwd: {{ web_root }}
    - require:
      - cmd: magento


# move the apps nginx rules to the site-enabled
{{ web_root }}app/etc/local.xml:
  file.managed:
    - source: {{ stage_root }}scripts/local.xml
    - show_diff: False
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}

insert-wsu-brand-favicon:
  cmd.run:
    - name: wget -q http://images.wsu.edu/favicon.ico -O favicon.ico
    - cwd: {{ web_root }}
    - require:
      - cmd: magento

###############################################
# staging
###############################################
{{ web_root }}staging/:
  file.directory:
    - name: {{ web_root }}staging/
    - user: www-data
    - group: www-data

{{ web_root }}staging/sql:
  cmd.run:
    - name: mkdir {{ web_root }}staging/sql | cp /var/app/{{ saltenv }}/provision/salt/stage/vagrant/sql/* {{ web_root }}staging/sql
    - user: root
    - unless: cd {{ web_root }}staging/sql
    
{{ web_root }}staging/scripts:
  cmd.run:
    - name: mkdir {{ web_root }}staging/scripts | cp /var/app/{{ saltenv }}/provision/salt/stage/vagrant/scripts/* {{ web_root }}staging/scripts
    - user: root
    - unless: cd {{ web_root }}staging/scripts

{{ web_root }}staging/patches:
  cmd.run:
    - name: mkdir {{ web_root }}staging/patches | cp /var/app/{{ saltenv }}/provision/salt/stage/vagrant/patches/* {{ web_root }}staging/patches
    - user: root
    - unless: cd {{ web_root }}staging/patches

###############################################
# patchs
###############################################
# this needs to be done in a better way
# we have to push the patch to be executable
###############################################
#run-patchs-2619-correct:
#  cmd.run: #insure it's going to run on windows hosts
#    - name: dos2unix /srv/salt/{{ saltenv }}/stage/vagrant/patches/PATCH_SUPEE-2619_EE_1.13.1.0_v1.sh
#run-patchs-2619:
#  cmd.script:
#    - name: PATCH_SUPEE-2619_EE_1.13.1.0_v1.sh
#    - source: {{ stage_root }}patches/PATCH_SUPEE-2619_EE_1.13.1.0_v1.sh
#    - cwd: {{ web_root }}
#    - unless: grep -qi "SUPEE-2619" {{ web_root }}app/etc/applied.patches.list  


