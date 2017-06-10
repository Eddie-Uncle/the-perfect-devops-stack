consul-template:
  description: 'consul-template'
  templates:
    - job_id: wp-dev
      destination: '/etc/nginx/conf.d/wp-dev.upstreams'
      command: 'systemctl restart nginx'
    - job_id: wp-prod
      destination: '/etc/nginx/conf.d/wp-prod.upstreams'
      command: 'systemctl restart nginx'
