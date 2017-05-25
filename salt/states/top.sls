base:
  'role:terraform':
    - match: grain
    - terraform

  'role:consul':
    - match: grain
    - consul
    - consul-template

  'role:nomad'
    - match: grain
    - nomad
