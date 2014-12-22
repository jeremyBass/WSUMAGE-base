{% set extpillars = pillars.magento_extensions -%}
extensions:
  {% for name,extension in extpillars -%}
  0000{{ loop.index }}--{{ name }}:
    track_name: {{ extension.track_name if extension.track_name else "" }}
    name: {{ extension.name if extension.name else "" }}
    repo_owner: {{ extension.repo_owner if extension.repo_owner else "" }}
    branch: {{ extension.branch if extension.branch else "master" }}
    tag: {{ extension.tag if extension.tag else "" }}
    rootfolder: {{ extension.rootfolder if extension.rootfolder else "" }}
    exclude: {{ extension.exclude if extension.exclude else "" }}
  {% endfor -%}

