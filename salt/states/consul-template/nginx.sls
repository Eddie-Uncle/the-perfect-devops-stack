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

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
        - file: nginx-yum-conf
