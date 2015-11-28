{% if pillars.magento_extensions is defined -%}
extensions:
  {% for name,extension in pillars.magento_extensions -%}
  ext{{ loop.index|leadingzero(5) }}--{{ name }}:
    track_name: "{{ extension.track_name if extension.track_name else extension.name|lower|replace("-","_")|replace(" ","_") }}"
    name: "{{ extension.name if extension.name else "" }}"
    repo_owner: "{{ extension.repo_owner if extension.repo_owner else "" }}"
    branch: "{{ extension.branch if extension.branch else "master" }}"
    tag: "{{ extension.tag if extension.tag else "" }}"
    rootfolder: "{{ extension.rootfolder if extension.rootfolder else "" }}"
    exclude: "{{ extension.exclude if extension.exclude else "" }}"
    protocol: "{{ extension.protocol if extension.protocol else "" }}"
  {% endfor -%}
{%- endif %}