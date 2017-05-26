{% from "nomad/map.jinja" import nomad with context %}

nomad-dep-unzip:
  pkg.installed:
    - name: unzip

nomad-bin-dir:
  file.directory:
   - name: {{ nomad.bin_dir }}
   - makedirs: True

nomad-download:
  file.managed:
    - name: /tmp/nomad_{{ nomad.version }}_linux_amd64.zip
    - source: https://{{ nomad.download_host }}/nomad/{{ nomad.version }}/nomad_{{ nomad.version }}_linux_amd64.zip
    - skip_verify: True
    - unless: {{ nomad.bin_dir }}/nomad-{{ nomad.version }} -v

nomad-extract:
  cmd.wait:
    - name: unzip /tmp/nomad_{{ nomad.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: nomad-download
    - unless: {{ nomad.bin_dir }}/nomad-{{ nomad.version }} -v

nomad-install:
  file.rename:
    - name: {{ nomad.bin_dir }}/nomad-{{ nomad.version }}
    - source: /tmp/nomad
    - require:
      - file: {{ nomad.bin_dir }}
    - watch:
      - cmd: nomad-extract

nomad-postclean:
  file.absent:
    - name: /tmp/nomad_{{ nomad.version }}_linux_amd64.zip
    - watch:
      - file: nomad-install

nomad-symlink:
  file.symlink:
    - target: {{ nomad.bin_dir }}/nomad-{{ nomad.version }}
    - name: {{ nomad.bin_dir }}/nomad
    - watch:
      - file: nomad-install
