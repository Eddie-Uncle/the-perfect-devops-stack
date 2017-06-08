{% from "docker/map.jinja" import docker with context %}

docker-pkg-deps:
  pkg.installed:
    - pkgs:
      - python2-pip

dockerrepo:
  cmd.run:
    - name: curl {{ docker.repourl }} -o /etc/yum.repos.d/docker-ce.repo
    - unless: test -f /etc/yum.repos.d/docker-ce.repo
    - require:
      - pkg: docker-pkg-deps

docker-py:
  pip.installed:
    - name: docker-py
    - require:
      - pkg: docker-pkg-deps

docker-ce:
  pkg.installed:
    - require:
      - cmd: dockerrepo

docker-opts-file:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://docker/files/daemon.json
    - require:
      - pkg: docker-ce
