# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}
{#%- set stage_root = "/var/app/{{ saltenv }}/provision/salt/stage/vagrant/" %#}
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
{% if not vars.isLocal %}
    - mode: 744
{%- endif %}

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
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"
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
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled=True"
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


###############################################
# staging
###############################################

{%- set web_stage_root = "{{ web_root }}staging/" %}
{{ web_root }}staging/:
  file.directory:
    - name: {{ web_root }}staging/
    - user: www-data
    - group: www-data

{{ web_stage_root }}sql:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}sql && cp {{ stage_root }}sql/* {{ web_stage_root }}sql
    - user: root
    - unless: cd {{ web_stage_root }}sql
    
{{ web_stage_root }}scripts:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}scripts && cp {{ stage_root }}scripts/* {{ web_stage_root }}scripts
    - user: root
    - unless: cd {{ web_stage_root }}scripts

{{ web_stage_root }}patches:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}patches && cp {{ stage_root }}patches/* {{ web_stage_root }}patches
    - user: root
    - unless: cd {{ web_stage_root }}patches

{{ web_stage_root }}settings:
  cmd.run:
    - name: mkdir -p {{ web_stage_root }}settings && cp {{ stage_root }}settings/* {{ web_stage_root }}settings
    - user: root
    - unless: cd {{ web_stage_root }}settings


###############################################
# patchs
###############################################
# this needs to be done in a better way
# we have to push the patch to be executable
###############################################
run-patches-4829-correct:
  cmd.run: #insure it's going to run on windows hosts
    - name: dos2unix {{ web_stage_root }}patches/SUPEE-4829.sh
run-patches-4829:
  cmd.script:
    - name: SUPEE-4829.sh
    - source: {{ web_stage_root }}patches/SUPEE-4829.sh
    - cwd: {{ web_root }}
    - unless: grep -qi "SUPEE-4829" {{ web_root }}app/etc/applied.patches.list  


