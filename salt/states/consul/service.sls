{% from "consul/map.jinja" import consul with context %}
consul-user:
  group.present:
    - name: consul
  user.present:
    - name: consul
    - createhome: false
    - system: true
    - groups:
      - consul
    - require:
      - group: consul

consul-config-dir:
  file.directory:
    - name: {{ consul.conf_dir }}
    - user: consul
    - group: consul
    - require:
      - user: consul-user

consul-data-dir:
  file.directory:
    - name: {{ consul.data_dir }}
    - user: consul
    - group: consul
    - makedirs: True
    - require:
      - user: consul-user

consul-config:
  file.managed:
    - name: {{ consul.conf_dir }}/config.json
    - source: salt://consul/files/config.json
    - user: consul
    - group: consul
    - require:
      - user: consul-user
    - template: jinja
    - context:
      is_server: {{ salt['pillar.get']('consul:is_server')  }}
      datacenter: {{ consul.config.datacenter }}
      data_dir: {{ consul.data_dir }}
      is_bootstrap: {{ salt['pillar.get']('consul:is_bootstrap')  }}

consul-systemd-file:
  file.managed:
    - source: salt://consul/files/consul.systemd
    - name: /etc/systemd/system/consul.service
    - mode: 0644

consul-service:
  service.running:
    - name: consul
    - enable: True
    - watch:
      - file: consul-config
      - file: consul-systemd-file

