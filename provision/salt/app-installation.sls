# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %} 
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/www/" + project['target'] + "/html/" %} 


PEAR-registry:
  cmd.run:
    - name: ./mage mage-setup .
    - cwd: {{ web_root }}

set-mage-ext-pref:
  cmd.run:
    - name: ./mage install magento-core Mage_All_Latest
    - cwd: {{ web_root }}

download-sample-date:
  file.directory:
    - name: {{ web_root }}/sampledata
    - user: www-data
    - group: www-data
  cmd.run:
    - name: git clone --depth=1 https://github.com/washingtonstateuniversity/WSUMAGE-sampledata.git sampledata | rm -rf !$/.git | cp -af {{ web_root }}sampledata/* {{ web_root }} 
    - cwd: {{ web_root }}/sampledata
    - user: root
    - require:
      - file: download-sample-date

install-sample-date:
  cmd.run:
    - name: mysql -h {{ magento['db_host'] }} -u {{ magento['db_user'] }} -p{{ magento['db_pass'] }} {{ magento['db_name'] }} < sample-data.sql
    - cwd: {{ web_root }}
    - require:
      - file: download-sample-date

clean-sample-date:
  cmd.run:
    - name: rm -rf WSUMAGE-sampledata-master/ sample-data.sql /sample-data-files
    - cwd: {{ web_root }}
    - user: root
    - require:
      - file: install-sample-date


#  if salt['service']('mysqld') is True 
#  endif 

magneto-install:
  cmd.run:
    - name: php -f install.php -- --license_agreement_accepted yes --locale {{ magento['locale'] }} --timezone {{ magento['timezone'] }} --default_currency {{ magento['default_currency'] }}  --db_host "{{ magento['db_host'] }}" --db_name "{{ magento['db_name'] }}" --db_user "{{ magento['db_user'] }}" --db_pass "{{ magento['db_pass'] }}" --url {{ magento['url'] }} --use_rewrites {{ magento['use_rewrites'] }} --skip_url_validation {{ magento['skip_url_validation'] }} --use_secure {{ magento['use_secure'] }} --secure_base_url {{ magento['secure_base_url'] }} --use_secure_admin {{ magento['use_secure_admin'] }} --admin_firstname "{{ magento['admin_firstname'] }}" --admin_lastname "{{ magento['admin_lastname'] }}" --admin_email "{{ magento['admin_email'] }}" --admin_username "{{ magento['admin_username'] }}" --admin_password "{{ magento['admin_password'] }}"
    - user: root
    - cwd: {{ web_root }}
    - require:
      - service: mysqld-{{ env }}


# Start the extension intsalls
#{% for ext_key, ext_val in magento_extensions.iteritems() %}
#base-ext-{{ ext_key }}:
#  cmd.run:
#    - name: modgit add {% if ext_val['tag'] is defined and ext_val['tag'] is not none %} -t {{ ext_val['tag'] }} {%- endif %} {% if ext_val['branch'] is defined and ext_val['branch'] is not none %} -b {{ ext_val['branch'] }} {%- endif %} {{ ext_key }} https://github.com/{{ ext_val['repo_owner'] }}/{{ ext_val['name'] }}.git
#    - cwd: {{ web_root }}
#    - user: root
#    - unless: ! modgit ls 2>/dev/null | grep -qi "{{ ext_key }}"
#    - require:
#      - service: mysqld-{{ env }}
#{% endfor %}




