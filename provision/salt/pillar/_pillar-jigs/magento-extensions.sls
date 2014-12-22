# this is the list and data for all the repositories thru gitploy
# gitploy add [-n] [-t tag_name] [-b branch_name] <module> <git_repository>
{% if pillars.extensions %}
extensions:
  {% for extension in pillars.extensions -%}
  0000{{ loop.index }}--{{ extension.name }}:
    track_name: {{ pillar.prefix if pillar.prefix else "" }}
    name: {{ pillar.prefix if pillar.prefix else "" }}
    repo_owner: {{ pillar.prefix if pillar.prefix else "" }}
    branch: {{ pillar.prefix if pillar.prefix else "master" }}
    tag: {{ pillar.prefix if pillar.prefix else "" }}
    rootfolder: {{ pillar.prefix if pillar.prefix else "" }}
    exclude: {{ pillar.prefix if pillar.prefix else "" }}
  {% endfor -%}
{%- endif %}

