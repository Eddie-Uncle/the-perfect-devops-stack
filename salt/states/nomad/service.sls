{% from "nomad/map.jinja" import nomad with context %}

nomad-config-dir:
  file.directory:
    - name: {{ nomad.conf_dir }}

nomad-data-dir:
  file.directory:
    - name: {{ nomad.data_dir }}
    - makedirs: True

nomad-config:
  file.managed:
    - name: {{ nomad.conf_dir }}/config.hcl
    - source: salt://nomad/files/config.hcl
    - require:
      - file: nomad-config-dir
    - template: jinja
    - context:
      stackhead_ip_address: {{ salt['pillar.get']('nomad:stackhead_ip_address')  }}
      datacenter: {{ nomad.config.datacenter }}
      data_dir: {{ nomad.data_dir }}
      is_bootstrap: {{ salt['pillar.get']('nomad:is_bootstrap')  }}

nomad-systemd-file:
  file.managed:
    - source: salt://nomad/files/nomad.systemd
    - name: /etc/systemd/system/nomad.service
    - mode: 0644

nomad-service:
  service.running:
    - name: nomad
    - enable: True
    - require:
      - file: nomad-systemd-file
    - watch:
      - file: nomad-config
      - file: nomad-systemd-file

