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

# move the apps nginx rules to the site-enabled
updatelocal.xml:
  file.managed:
    - name: {{ web_root }}app/etc/local.xml
    - source: {{ stage_root }}config/mage/local.xml
    - onlyif: printenv 2>&1 | grep -qi "MagentoInstalled=True"
    - show_diff: False
    - replace: True
    - template: jinja
    - context:
      magento: {{ magento }}
      database: {{ database }}
      project: {{ project }}
      saltenv: {{ saltenv }}

# Database actions
##########################################################
## Note this should test for it being requested to be done,
## not just assumed that it should be if it's there

{% if magento['db_restore_host'] %}
db_bak:
  file.directory:
    - name: /var/app/db_bak/{{ saltenv }}/
    - makedirs: True
    - user: root
    - group: root

get-backup:
  cmd.run:
    - name: "mysqldump -h{{ magento['db_restore_host'] }} -u{{ magento['db_restore_user'] }} -p{{ magento['db_restore_pass'] }} {{ magento['db_restore_db'] }} > /var/app/db_bak/{{ saltenv }}/current--{{ saltenv }}.sql"
{%- endif %}

load-backup:
  cmd.run:
    - name: "mysql -h{{ database['host'] }} -u{{ database['user'] }} -p{{ database['pass'] }} {{ database['name'] }} < /var/app/db_bak/{{ saltenv }}/current--{{ saltenv }}.sql"
    - onlyif: test -f /var/app/db_bak/{{ saltenv }}/current--{{ saltenv }}.sql



