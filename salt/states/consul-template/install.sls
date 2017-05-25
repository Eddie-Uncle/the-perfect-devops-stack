{% from "consul-template/map.jinja" import consul-template with context %}

consul-template-dep-unzip:
  pkg.installed:
    - name: unzip

consul-template-bin-dir:
  file.directory:
   - name: {{ consul-template.bin_dir }}
   - makedirs: True

consul-template-download:
  file.managed:
    - name: /tmp/consul-template_{{ consul-template.version }}_linux_amd64.zip
    - source: https://{{ consul-template.download_host }}/consul-template/{{ consul-template.version }}/consul-template_{{ consul-template.version }}_linux_amd64.zip
    - skip_verify: True
    - unless: test -f {{ consul-template.bin_dir }}/consul-template_{{ consul-template.version }}

consul-template-extract:
  cmd.wait:
    - name: unzip /tmp/consul-template_{{ consul-template.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul-template-download

consul-template-install:
  file.rename:
    - name: {{ consul-template.bin_dir }}/consul-template-{{ consul-template.version }}
    - source: /tmp/consul-template
    - require:
      - file: {{ consul-template.bin_dir }}
    - watch:
      - cmd: consul-template-extract

consul-template-postclean:
  file.absent:
    - name: /tmp/consul-template_{{ consul-template.version }}_linux_amd64.zip
    - watch:
      - file: consul-template-install

consul-template-symlink:
  file.symlink:
    - target: {{ consul-template.bin_dir }}/consul-template-{{ consul-template.version }}
    - name: {{ consul-template.bin_dir }}/consul-template
    - watch:
      - file: consul-template-install
