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

  'role:web':
    - match: grain
    - consul-template.nginx

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
