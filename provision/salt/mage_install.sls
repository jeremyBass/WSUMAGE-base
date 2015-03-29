# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{#%- set stage_root = "salt://stage/vagrant/" %#}
{%- set stage_root = "/var/app/" + saltenv + "/provision/salt/stage/vagrant/" %}
{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': salt['cmd.run']('ifconfig eth1 | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}

###############################################
# install Magento via CLI
###############################################
magneto-install:
  cmd.run:
    - name: 'tmp=$(php -f install.php -- --license_agreement_accepted yes --locale {{ magento['locale'] }} --timezone {{ magento['timezone'] }} --default_currency {{ magento['default_currency'] }}  --db_host "{{ database['host'] }}" --db_name "{{ database['name'] }}" --db_user "{{ database['user'] }}" --db_pass "{{ database['pass'] }}" {% if database['prefix'] is defined and database['prefix'] is not none %} --db_prefix "{{ database['prefix'] }}" {%- endif %} --url {{ magento['url'] }} --use_rewrites {{ magento['use_rewrites'] }} --skip_url_validation {{ magento['skip_url_validation'] }} --use_secure {{ magento['use_secure'] }} --secure_base_url {{ magento['secure_base_url'] }} --use_secure_admin {{ magento['use_secure_admin'] }} --admin_firstname "{{ magento['admin_firstname'] }}" --admin_lastname "{{ magento['admin_lastname'] }}" --admin_email "{{ magento['admin_email'] }}" --admin_username "{{ magento['admin_username'] }}" --admin_password "{{ magento['admin_password'] }}"  3>&1 1>&2 2>&3) && echo "export MagentoInstalled_Fresh=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/environment && echo "export MagentoInstalled=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/environment && echo $tmp'
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"
    - user: root
    - cwd: {{ web_root }}
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}

###############################################
# patchs
###############################################
# this needs to be done in a better way
# we have to push the patch to be executable
###############################################
run-patches-4829-correct:
  cmd.run: #insure it's going to run on windows hosts
    - name: dos2unix {{ stage_root }}patches/SUPEE-4829.sh
run-patches-4829:
  cmd.script:
    - name: sh SUPEE-4829.sh
    - source: /var/app/" + saltenv + "/provision/salt/patches/SUPEE-4829.sh
    - cwd: {{ web_root }}
    - unless: grep -qi "SUPEE-4829" {{ web_root }}app/etc/applied.patches.list  


###############################################
# connect settings
###############################################
magneto-set-connect-prefs:
  cmd.run:
    - name: ./mage config-set preferred_state alpha | ./mage clear-cache | ./mage sync
    - cwd: {{ web_root }}
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled=True"
    - require:
      - cmd: magento


###############################################
# match install local.xml
###############################################
newlocal.xml:
  file.managed:
    - name: {{ web_root }}app/etc/local.xml
    - source: /var/app/" + saltenv + "/provision/salt/config/mage/local.xml
    - onlyif: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"
    - show_diff: False
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}



