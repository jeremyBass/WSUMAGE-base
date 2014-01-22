store.wsu.edu:
  '*':
    - project_manager
    - env
    - sample-data
    - app-installation
    - extensions
  'env:vagrant':
    - match: grain
    - stage-dev
  'env:production':
    - match: grain
    - stage-prod
