store.wsu.edu:
  '*':
    - project_manager
    - environment
    - install
  'env:vagrant':
    - match: grain
    - stage-dev
  'env:production':
    - match: grain
    - stage-prod
