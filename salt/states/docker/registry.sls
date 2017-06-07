{% from "docker/map.jinja" import docker with context %}

docker-registry:
  dockerng.running:
    - name: {{ docker.registry_name }}
    - image: {{ docker.registry_image }}
    - port_bindings:
      - 5000:5000
    - require:
      - service: docker
