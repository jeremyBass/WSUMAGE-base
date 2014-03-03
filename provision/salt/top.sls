# set up data first
###########################################################
{%- set project = pillar.get('project') %}
{%- set database = pillar.get('database') %}
{%- set magento = pillar.get('magento') %}
{%- set magento_version = magento['version'] %}
{%- set magento_extensions = pillar.get('extensions',{}) %}
{%- set web_root = "/var/app/" + saltenv + "/html/" %}
{%- set stage_root = "salt://stage/vagrant/" %}

store.wsu.edu:
  '*':
    - project_manager
    - env
    - sample_data
    - app_installation
    - extensions
  'saltenv:vagrant':
    - match: grain
    - settings_dev
    - stage_dev
    - clean
  'saltenv:production':
    - match: grain
    - stage_prod
    - clean
