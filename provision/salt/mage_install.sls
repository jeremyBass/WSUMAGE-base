# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set MAGE = pillar.get('magento') %}
{%- set magento_version = MAGE['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{#%- set stage_root = "salt://stage/vagrant/" %#}
{%- set stage_root = "/var/app/" + saltenv + "/provision/salt/stage/vagrant/" %}
{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': salt['cmd.run']('(ifconfig eth1 2>/dev/null || ifconfig eth0 2>/dev/null) | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}


###############################################
# install Magento via CLI
###############################################
# look to http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html#instgde-install-cli-magento
magneto-install:
  cmd.run:
    - name: |
       php bin/magento setup:upgrade --no-interaction || php bin/magento setup:install --no-interaction \
        --admin-firstname="{{ MAGE['admin-firstname'] }}" \
        --admin-lastname="{{ MAGE['admin-lastname'] }}" \
        --admin-email="{{ MAGE['admin-email'] }}" \
        --admin-user="{{ MAGE['admin-user'] }}" \
        --admin-password="{{ MAGE['admin-password'] }}" \
        --base-url={{ MAGE['url'] }} \
        --backend-frontname="{{ MAGE['backend-frontname'] }}" \
        --db-host="{{ MAGE['db-host'] }}" \
        --db-name="{{ MAGE['db-name'] }}" \
        --db-user="{{ MAGE['db-user'] }}" \
        --db-password="{{ MAGE['db-password'] }}" \
        --db-prefix="{{ MAGE['db-prefix'] }}" \
        --language="{{ MAGE['language'] }}" \
        --currency={{ MAGE['currency'] }} \
        --timezone={{ MAGE['timezone'] }} \
        --use-rewrites={{ MAGE['use-rewrites'] }} \
        --use-secure={{ MAGE['use-secure'] }} \
        --base-url-secure={{ MAGE['base-url-secure'] }} \
        --use-secure-admin={{ MAGE['use-secure-admin'] }} \
        --admin-use-security-key={{ MAGE['admin-use-security-key'] }} \
        --session-save={{ MAGE['session-save'] }} \
        --key={{ MAGE['key'] }} \
        {{ "--cleanup-database" if MAGE['cleanup-database'] == 1 else "" }} \
        --db-init-statements="{{ MAGE['db-init-statements'] }}" \
        --sales-order-increment-prefix="{{ MAGE['sales-order-increment-prefix'] }}" \
        && echo "export MagentoInstalled_Fresh=True {% raw %}#salt-set REMOVE{% endraw %}" >> /etc/environment
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
#magneto-set-connect-prefs:
#  cmd.run:
#    - name: ./mage config-set preferred_state alpha | ./mage clear-cache | ./mage sync
#    - cwd: {{ web_root }}
#    - unless: printenv 2>&1 | grep -qi "MagentoInstalled=True"
#    - require:
#      - cmd: magento


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
      magento: {{ MAGE }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}

###############################################
# connect settings
###############################################
static-content-deploy:
  cmd.run:
    - name: php bin/magento setup:static-content:deploy
    - cwd: {{ web_root }}
    - require:
      - cmd: magneto-install

