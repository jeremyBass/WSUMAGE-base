store.wsu.edu:
  '*':
    - project_manager
  'env:vagrant':
    - match: grain
    - wsumage-dev
  'env:production':
    - match: grain
    - wsumage-prod
