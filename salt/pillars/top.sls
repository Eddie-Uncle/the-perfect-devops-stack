base:
  '*':
     - dnsmasq

  'role:stackhead':
    - match: grain
    - terraform
    - consul
    - consul.server
    - consul-template
    - nomad

  'role:terraform':
    - match: grain
    - terraform

  'role:consul':
    - match: grain
    - consul
    - consul-template

  'role:nomad':
    - match: grain
    - nomad
