store.wsu.edu:
  '*':
    - project_manager
    - env
    - app-installation
  'env:vagrant':
    - match: grain
    - stage-dev
  'env:production':
    - match: grain
    - stage-prod
