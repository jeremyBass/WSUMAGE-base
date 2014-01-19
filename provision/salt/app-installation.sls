# set up data first
###########################################################
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}



# Start the extension intsalls
{% for ext_key, ext_val in magento_extensions.iteritems() %}
base-ext-{{ ext_key }}:
  cmd.run:
    - name: modgit add {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ ext_key }} https://github.com/{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git
    - cwd: /var/www/store.wsu.edu/html/
    - unless: ! modgit ls 2>/dev/null | grep -qi {{ ext_key }}
{% endfor %}

/var/www/store.wsu.edu/html/mage-{{ magento_version }}.txt:
  file.managed:
    - user: www-data
    - group: www-data








