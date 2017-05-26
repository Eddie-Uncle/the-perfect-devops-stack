{% from "consul/map.jinja" import consul with context %}

consul-dep-unzip:
  pkg.installed:
    - name: unzip

consul-bin-dir:
  file.directory:
   - name: {{ consul.bin_dir }}
   - makedirs: True

consul-download:
  file.managed:
    - name: /tmp/consul_{{ consul.version }}_linux_amd64.zip
    - source: https://{{ consul.download_host }}/consul/{{ consul.version }}/consul_{{ consul.version }}_linux_amd64.zip
    - skip_verify: True
    - unless: {{ consul.bin_dir }}/consul-{{ consul.version }} -v

consul-extract:
  cmd.wait:
    - name: unzip /tmp/consul_{{ consul.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul-download

consul-install:
  file.rename:
    - name: {{ consul.bin_dir }}/consul-{{ consul.version }}
    - source: /tmp/consul
    - require:
      - file: {{ consul.bin_dir }}
    - watch:
      - cmd: consul-extract
    - unless: {{ consul.bin_dir }}/consul-{{ consul.version }} -v

consul-postclean:
  file.absent:
    - name: /tmp/consul_{{ consul.version }}_linux_amd64.zip
    - watch:
      - file: consul-install

consul-symlink:
  file.symlink:
    - target: {{ consul.bin_dir }}/consul-{{ consul.version }}
    - name: {{ consul.bin_dir }}/consul
    - watch:
      - file: consul-install
