# We set up projects based on what is set up in the pillar data
# find settings in pillar/projects.sls


{%- set project = pillar.get['project'] -%}
{% if project is defined and project['name'] != '' %}

{%- set project_root = '/var/www/' + project['target'] -%}
{%- set project_web_root = project_root+'/html/' -%}

load-project-{{ project['name'] }}:
  git.latest:
    - name: {{ project['name'] }}
    - target: {{ project_root }}
    - unless: cd {{ project_root }}/provision/salt/config
    {% if project['rev'] is defined and project['rev'] != '' %}- rev: {{ project['rev'] }}{%- endif %}
    {% if project['remote_name'] is defined and project['remote_name'] != '' %}- remote_name: {{ project['remote_name'] }}{%- endif %}
    {% if project.get( 'force', False ) is sameas True %}- force: True{%- endif %}
    {% if project.get( 'submodules', False ) is sameas True %}- submodules: True{%- endif %}
    {% if project.get( 'force_checkout', False ) is sameas True %}- force_checkout: True{%- endif %}
    {% if project.get( 'mirror', False ) is sameas True %}- mirror: True{%- endif %}
    {% if project.get( 'bare', False ) is sameas True %}- bare: True{%- endif %}
    {% if project['identity'] is defined and project['identity'] != '' %}- identity: {{ project['identity'] }}{%- endif %}
    {% if project['user'] is defined and project_arg['user'] != '' %}- user: {{ project['user'] }}{%- endif %}
{% endif %}
