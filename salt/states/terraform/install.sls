{% from "terraform/map.jinja" import terraform with context %}

terraform-dep-unzip:
  pkg.installed:
    - name: unzip

terraform-bin-dir:
  file.directory:
   - name: {{ terraform.bin_dir }}
   - makedirs: True

terraform-download:
  file.managed:
    - name: /tmp/terraform_{{ terraform.version }}_linux_amd64.zip
    - source: https://{{ terraform.download_host }}/terraform/{{ terraform.version }}/terraform_{{ terraform.version }}_linux_amd64.zip
    - skip_verify: True
    - unless: test -f {{ terraform.bin_dir }}/terraform_{{ terraform.version }}

terraform-extract:
  cmd.wait:
    - name: unzip /tmp/terraform_{{ terraform.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: terraform-download

terraform-install:
  file.rename:
    - name: {{ terraform.bin_dir }}/terraform-{{ terraform.version }}
    - source: /tmp/terraform
    - require:
      - file: {{ terraform.bin_dir }}
    - watch:
      - cmd: terraform-extract

terraform-postclean:
  file.absent:
    - name: /tmp/terraform_{{ terraform.version }}_linux_amd64.zip
    - watch:
      - file: terraform-install

terraform-symlink:
  file.symlink:
    - target: {{ terraform.bin_dir }}/terraform-{{ terraform.version }}
    - name: {{ terraform.bin_dir }}/terraform
    - watch:
      - file: terraform-install
