{% from "dnsmasq/map.jinja" import dnsmasq with context %}

dnsmasq-config:
  file.managed:
    - name: {{ dnsmasq.conf_file }}
    - source: salt://dnsmasq/files/10-consul
    - template: jinja
    - context:
      forwarder_ip: {{ dnsmasq.config.forwarder }} 

dnsmasq-service:
  service.running:
    - name: dnsmasq
    - enable: True
    - watch:
      - pkg: dnsmasq
      - file: dnsmasq-config

/etc/resolv.conf:
  file.managed:
    - name: /etc/resolv.conf
    - contents: 
      - nameserver 127.0.0.1
