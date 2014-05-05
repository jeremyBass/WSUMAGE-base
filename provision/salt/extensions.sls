# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}
{%- set isLocal = "false" -%}
{% for host,ip in salt['mine.get']('*', 'network.ip_addrs').items() -%}
    {% if ip|replace("10.255.255", "LOCAL").split('LOCAL').count() == 2  %}
        {%- set isLocal = "true" -%}
    {%- endif %}
{%- endfor %}


remove-PaypalUk:
  cmd.run:
    - name: rm -rf app/code/core/Mage/PaypalUk/*
    - user: root
    - cwd: {{ web_root }}

remove-Mage_Authorizenet:
  cmd.run:
    - name: rm -rf app/code/core/Mage/Authorizenet/* app/etc/modules/Mage_Authorizenet.xml
    - user: root
    - cwd: {{ web_root }}

remove-Phoenix_Moneybookers:
  cmd.run:
    - name: rm -rf app/code/core/community/Phoenix/* app/etc/modules/Phoenix_Moneybookers.xml
    - user: root
    - cwd: {{ web_root }}
      
#come back on this one.. unsure   
#rm -rf app/code/core/Mage/Paypal/* app/code/core/Mage/Paypal/*
#rm -rf app/design/adminhtml/default/default/template/paypal/*




# Start the extension intsalls
{% for ext_key, ext_val in magento_extensions|dictsort %}

{%- set installExt = "true" -%}
{%- set track_name = ext_val['track_name'] -%}


{% if ext_val['localonly'] is defined and ext_val['localonly'] is not none and ext_val['localonly'] == "true" %}
        {%- set installExt = isLocal -%}
{%- endif %}

{% if installExt == "true" %}

base-ext-{{ ext_key }}:
  cmd.run:
    - name: 'gitploy -q {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ track_name }} https://github.com/{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git && echo "export ADDED{{ track_name|replace("-","") }}=True {% raw %}#salt-set REMOVE{% endraw %}-{{ ext_key }}" >> /etc/profile'
    - cwd: {{ web_root }}
    - user: root
    - unless: modgit ls 2>&1 | grep -qi "{{ track_name }}"
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
    - unless: test x"$ADDED{{ track_name|replace("-","") }}" = x
    - require:
      - cmd: magento
      - service: mysqld-{{ saltenv }}
      - service: php-{{ saltenv }}
      - cmd: magneto-install      

{% else %}
{%- endif %}

{% endfor %}



