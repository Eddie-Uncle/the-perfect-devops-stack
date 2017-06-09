{% from "docker/map.jinja" import docker with context %}

etc-docker:
  file.directory:
    - name: /etc/docker
    - user: root
    - group: root
    - mode: 0755

docker-opts-file:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://docker/files/daemon.json
    - require:
      - file: etc-docker
      - pkg: docker-ce

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - file: docker-opts-file
      - pkg: docker-ce
      - pip: docker-py
    - watch:
      - file: docker-opts-file
