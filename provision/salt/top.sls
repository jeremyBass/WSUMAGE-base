store.wsu.edu:
  '*':
    - project_manager
    - env
    - sample_data
    - app_installation
    - extensions
  'env:vagrant':
    - match: grain
    - settings_dev
    - stage_dev
  'env:production':
    - match: grain
    - stage_prod
