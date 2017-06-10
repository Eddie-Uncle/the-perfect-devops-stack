consul-template:
  description: 'consul-template'
  templates:
    - job_id: wp-dev
      destination: '/etc/nginx/conf.d/wp-dev.upstreams'
      command: 'systemctl restart nginx'
