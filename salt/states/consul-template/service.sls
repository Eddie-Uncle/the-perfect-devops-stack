{% from "consul-template/map.jinja" import consul_template with context %}
consul-template-config-dir:
  file.directory:
    - name: {{ consul_template.conf_dir }}

consul-template-templates-dir:
  file.directory:
    - name: {{ consul_template.conf_dir }}/templates
    - require:
       - file: consul-template-config-dir

consul-template-config:
  file.managed:
    - name: {{ consul_template.conf_dir }}/config.json
    - source: salt://consul-template/files/config.json
    - template: jinja
    - context:
      consul_template: {{ consul_template }}
      templates: {{ consul_template.templates }}
    - require:
       - file: consul-template-config-dir

consul-template-systemd-file:
  file.managed:
    - source: salt://consul-template/files/consul-template.systemd
    - name: /etc/systemd/system/consul-template.service
    - mode: 0644

{% for f in consul_template.templates %}
template-{{ f.job_id }}:
  file.managed:
      - name: {{ consul_template.conf_dir }}/templates/{{ f.job_id }}.ctmpl
      - source: salt://consul-template/files/template-nginx-upstreams
      - template: jinja
      - context:
          job_id: {{ f.job_id }}
{% endfor %}

consul-template-service:
  service.running:
    - name: consul-template
    - enable: True
    - watch:
      - file: consul-template-config
      - file: consul-template-systemd-file
      - file: {{ consul_template.conf_dir }}/templates/*.ctmpl
