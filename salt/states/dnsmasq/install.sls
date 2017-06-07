{% from "dnsmasq/map.jinja" import dnsmasq with context %}

dnsmasq-install:
  pkg.installed:
    - name: dnsmasq
