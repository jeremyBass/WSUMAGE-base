base:
  'env:vagrant':
    - match: grain
    - devserver
    - wsumage-dev
  'env:production':
    - match: grain
    - wsumage-prod
