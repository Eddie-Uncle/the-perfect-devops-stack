{% from "docker/map.jinja" import docker with context %}

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-ce
      - pip: docker-py
