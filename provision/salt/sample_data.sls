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
{% if vars.update({'ip': salt['cmd.run']('(ifconfig eth1 2>/dev/null || ifconfig eth0 2>/dev/null) | grep "inet " | awk \'{gsub("addr:","",$2);  print $2 }\'') }) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('test -n "$SERVER_TYPE" && echo $SERVER_TYPE || echo "false"') }) %} {% endif %}

## note it should be that only on need does this get run
## question what the need is, then test for it

{% if magento['sample_data'] == "True" %}
## if the repo of sample data exists
reload-sampledata:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: gitploy re -q -b 2.0 sampledata
    - cwd: {{ web_root }}
    - user: root

##else load it
load-sampledata:
  cmd.run:
    - unless: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: gitploy ls 2>&1 | grep -qi "MAGE" && gitploy -q -b 2.0 sampledata https://github.com/magento/magento2-sample-data.git
    - cwd: {{ web_root }}
    - user: root
    - require:
      - service: reload-sampledata
##end

##Link the sample data
link-sample-date:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: php -f {{ web_root }}dev/tools/build-sample-data.php -- --ce-source="{{ web_root }}"
    - cwd: {{ web_root }}
    - require:
      - service: load-sampledata

##Link the sample data
install-sample-date:
  cmd.run:
    - name: php bin/magento setup:upgrade
    - cwd: {{ web_root }}

{% else %}


##Link the sample data
unlink-sample-date:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: php -f {{ web_root }}dev/tools/build-sample-data.php -- --command=unlink --ce-source="{{ web_root }}"
    - cwd: {{ web_root }}

remove-sampledata:
  cmd.run:
    - onlyif: gitploy ls 2>&1 | grep -qi "sampledata"
    - name: gitploy rm -q -u sampledata
    - cwd: {{ web_root }}
    - user: root

##Link the sample data
uninstall-sample-date:
  cmd.run:
    - name: php bin/magento setup:upgrade
    - cwd: {{ web_root }}
{%- endif %}
