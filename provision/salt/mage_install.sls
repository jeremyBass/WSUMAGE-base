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
{% if vars.update({'ip': salt['cmd.run']('(ifconfig eth1 2>/dev/null || ifconfig eth0 2>/dev/null) | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}

###############################################
# Setup the magento CLI path
###############################################
magneto-cli-setup:
  cmd.run:
    - name: export PATH=$PATH:{{ web_root }}bin
    - cwd: {{ web_root }}

###############################################
# install Magento via CLI
###############################################
magneto-install:
  cmd.run:
    - name: 'tmp=$(magento setup:install --language={{ magento['locale'] }} --timezone={{ magento['timezone'] }} --currency={{ magento['default_currency'] }}  --db-host="{{ database['host'] }}" --db-name="{{ database['name'] }}" --db-user="{{ database['user'] }}" --db-password="{{ database['pass'] }}" {% if database['prefix'] is defined and database['prefix'] is not none %} --db-prefix="{{ database['prefix'] }}" {%- endif %} --base-url={{ magento['url'] }} --use-rewrites={{ magento['use_rewrites'] }} --use-secure={{ magento['use_secure'] }} --base-url-secure={{ magento['secure_base_url'] }} --use-secure-admin={{ magento['use_secure_admin'] }} --admin-firstname="{{ magento['admin_firstname'] }}" --admin-lastname="{{ magento['admin_lastname'] }}" --admin-email="{{ magento['admin_email'] }}" --admin-user="{{ magento['admin_username'] }}" --admin-password="{{ magento['admin_password'] }}"  3>&1 1>&2 2>&3) && echo "export MagentoInstalled_Fresh=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/environment && echo $tmp'
    - unless: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"
    - user: root
    - cwd: {{ web_root }}
    - require:
      - cmd: magento
      - cmd: magneto-cli-setup
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}

###############################################
# patchs
###############################################
# this needs to be done in a better way
# we have to push the patch to be executable
###############################################
#run-patches-5994-correct:
#  cmd.run: #insure it's going to run on windows hosts
#    - name: dos2unix /var/app/{{ saltenv }}/provision/salt/patches/SUPEE-5994.sh
#run-patches-5994:
#  cmd.script:
#    - name: sh SUPEE-5994.sh
#    - source: /var/app/{{ saltenv }}/provision/salt/patches/SUPEE-5994.sh
#    - cwd: {{ web_root }}
#    - unless: grep -qi "SUPEE-5994" {{ web_root }}app/etc/applied.patches.list  



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
    - source: /var/app/{{ saltenv }}/provision/salt/config/mage/local.xml
    - onlyif: printenv 2>&1 | grep -qi "MagentoInstalled_Fresh=True"
    - show_diff: False
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}



