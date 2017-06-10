{% from "consul-template/map.jinja" import consul_template with context %}

nginx-yum-repo:
  file.managed:
    - name: /etc/yum.repos.d/nginx.repo
    - source: salt://consul-template/files/nginx-yum.repo
    - user: root
    - group: root
    - mode: 0644

nginx-pkg:
  pkg.installed:
    - name: nginx
    - require:
       - file: nginx-yum-repo

nginx-yum-conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://consul-template/files/nginx-conf
    - user: root
    - group: root
    - mode: 0644
    - require:
        - pkg: nginx-pkg

{% for f in consul_template.templates %}
template-{{ f.job_id }}:
  file.managed:
      - name: {{ consul_template.conf_dir }}/templates/{{ f.job_id }}.ctmpl
      - source: salt://consul-template/files/template-nginx-upstreams
      - template: jinja
      - context:
          job_id: {{ f.job_id }}
{% endfor %}

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
        - file: nginx-yum-conf
        - file: {{ consul_template.conf_dir }}/templates/*.ctmpl
