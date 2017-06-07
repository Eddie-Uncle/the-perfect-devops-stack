{% from "docker/map.jinja" import docker with context %}

docker-registrator:
  dockerng.running:
    - name: {{ docker.registrator_name }}
    - image: {{ docker.registrator_image }}
    - binds:
      - /var/run/docker.sock:/tmp/docker.sock
    - cmd: "consul://localhost:8500"
    - network_mode: host
    - require:
      - service: docker
      - service: consul-service
