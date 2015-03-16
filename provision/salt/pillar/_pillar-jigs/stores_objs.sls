{% set stores = pillars.stores -%}
stores_objs:
  {% for name,store in stores -%}
  "{{ name }}":
    track_name: "{{ store.track_name if store.track_name else store.name|lower|replace("-","_")|replace(" ","_") }}"
    name: "{{ store.name if store.name else "" }}"
    repo_owner: "{{ store.repo_owner if store.repo_owner else "" }}"
    branch: "{{ store.branch if store.branch else "master" }}"
    tag: "{{ store.tag if store.tag else "" }}"
    rootfolder: "{{ store.rootfolder if store.rootfolder else "" }}"
    exclude: "{{ store.exclude if store.exclude else "" }}"
    protocol: "{{ store.protocol if store.protocol else "" }}"
  {% endfor -%}