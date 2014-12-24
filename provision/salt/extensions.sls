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


{% if magento.trim_defaultext == "true" %}
remove-PaypalUk:
  cmd.run:
    - name: rm -rf app/code/core/Mage/PaypalUk/*
    - user: root
    - cwd: {{ web_root }}
    - onlyif: test -d app/code/core/Mage/PaypalUk/

remove-Mage_Authorizenet:
  cmd.run:
    - name: rm -rf app/code/core/Mage/Authorizenet/* app/etc/modules/Mage_Authorizenet.xml
    - user: root
    - cwd: {{ web_root }}
    - onlyif: test -d app/code/core/Mage/Authorizenet/

remove-Phoenix_Moneybookers:
  cmd.run:
    - name: rm -rf app/code/core/community/Phoenix/* app/etc/modules/Phoenix_Moneybookers.xml
    - user: root
    - cwd: {{ web_root }}
    - onlyif: test -d app/code/core/community/Phoenix/
      
#come back on this one.. unsure   
#rm -rf app/code/core/Mage/Paypal/* app/code/core/Mage/Paypal/*
#rm -rf app/design/adminhtml/default/default/template/paypal/*
{%- endif %}



# Start the extension intsalls
{% for ext_key, ext_val in magento_extensions|dictsort %}

{%- set installExt = "true" -%}
{%- set track_name = ext_val['track_name'] -%}


{% if ext_val['localonly'] is defined and ext_val['localonly'] is not none and ext_val['localonly'] == "true" %}
        {%- set installExt = var.isLocal -%}
{%- endif %}

{% if installExt == "true" %}

base-ext-{{ ext_key }}-update:
  cmd.run:
    - name: 'gitploy up -q {% if ext_val['exclude'] is defined and ext_val['exclude'] is not none %} -e {{ ext_val['exclude'] }} {%- endif %} {% if ext_val['rootfolder'] is defined and ext_val['rootfolder'] is not none %} -f {% raw %}"{% endraw %}{{ ext_val['rootfolder'] }}{% raw %}"{% endraw %} {%- endif %} {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ track_name }} {% if ext_val['protocal'] is defined and ext_val['protocol'] is not none %}{{ ext_val['protocol'] }}{%- else %}https://github.com/{%- endif %}{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git'
    - cwd: {{ web_root }}
    - user: root
    - onlyif: gitploy ls 2>&1 | grep -qi "{{ track_name }}"

base-ext-{{ ext_key }}:
  cmd.run:
    - name: 'gitploy -q {% if ext_val['exclude'] is defined and ext_val['exclude'] is not none %} -e {{ ext_val['exclude'] }} {%- endif %} {% if ext_val['rootfolder'] is defined and ext_val['rootfolder'] is not none %} -f {% raw %}"{% endraw %}{{ ext_val['rootfolder'] }}{% raw %}"{% endraw %} {%- endif %} {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ track_name }} https://github.com/{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git && echo "export ADDED{{ track_name|replace("-","") }}=True {% raw %}#salt-set REMOVE{% endraw %}-{{ ext_key }}" >> /etc/environment'
    - cwd: {{ web_root }}
    - user: root
    - unless: gitploy ls 2>&1 | grep -qi "{{ track_name }}"
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install
      - cmd: init_gitploy
      
install-base-ext-{{ ext_key }}:
  cmd.run:
    - name: rm -rf {{ web_root }}var/cache/* | php "{{ web_root }}index.php" 2>/dev/null
    - cwd: {{ web_root }}
    - user: root
#    - unless: test x"$ADDED{{ track_name|replace("-","") }}" = x
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install      

{% else %}
{%- endif %}

{% endfor %}



