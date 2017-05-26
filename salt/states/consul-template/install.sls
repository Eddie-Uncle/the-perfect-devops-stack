{% from "consul-template/map.jinja" import consul_template with context %}

consul_template-dep-unzip:
  pkg.installed:
    - name: unzip

consul_template-bin-dir:
  file.directory:
   - name: {{ consul_template.bin_dir }}
   - makedirs: True

consul_template-download:
  file.managed:
    - name: /tmp/consul_template_{{ consul_template.version }}_linux_amd64.zip
    - source: https://{{ consul_template.download_host }}/consul-template/{{ consul_template.version }}/consul-template_{{ consul_template.version }}_linux_amd64.zip
    - skip_verify: True
    - unless: {{ consul_template.bin_dir }}/consul-template-{{ consul_template.version }} -v
consul_template-extract:
  cmd.wait:
    - name: unzip /tmp/consul_template_{{ consul_template.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul_template-download

consul_template-install:
  file.rename:
    - name: {{ consul_template.bin_dir }}/consul-template-{{ consul_template.version }}
    - source: /tmp/consul-template
    - require:
      - file: {{ consul_template.bin_dir }}
    - watch:
      - cmd: consul_template-extract
    - unless: {{ consul_template.bin_dir }}/consul-template-{{ consul_template.version }} -v

consul_template-postclean:
  file.absent:
    - name: /tmp/consul_template_{{ consul_template.version }}_linux_amd64.zip
    - watch:
      - file: consul_template-install

consul_template-symlink:
  file.symlink:
    - target: {{ consul_template.bin_dir }}/consul-template-{{ consul_template.version }}
    - name: {{ consul_template.bin_dir }}/consul-template
    - watch:
      - file: consul_template-install
