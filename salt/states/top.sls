base:
  '*':
    - dnsmasq

  'role:stackhead':
    - match: grain
    - terraform
    - consul
    - consul-template
    - nomad
    - docker
    - docker.registry

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

  'role:docker':
    - match: grain
    - docker

  'role:registrator':
    - match: grain
    - docker.registrator
