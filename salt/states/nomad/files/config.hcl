datacenter = "{{ datacenter }}"
data_dir = "{{ data_dir }}"
{% if is_bootstrap -%}
server {
  enabled = true
  bootstrap_expect = 1
  retry_join = [ "{{ stackhead_ip_address }}"]
}
{%- else %}
client {
  enabled = true
  servers = [ "{{ stackhead_ip_address }}"]
}
{%- endif %}
