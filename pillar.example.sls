{# Master Host (high prio) #}
keepalived:
  configs:
    01_global_defs:
      sections:
        - comment: Global settings
          type: global_defs
          settings:
            notification_email:
              - hostmaster@example.net
            notification_email_from: root@{{ salt['grains.get']('fqdn') }}
            smtp_server: 127.0.0.1
            smtp_connect_timeout: 30
            router_id: id_TBD_TODO
    02_virtual_instances:
      sections:
        - comment: HTTP Software Repositories
          name: VI_1
          type: vrrp_instance
          settings:
            state: BACKUP
            smtp_alert: ''
            interface: eth0
            virtual_router_id: 51
            priority: 100
            advert_int: 1
            authentication:
              auth_type: PASS
              auth_pass: foobar
            virtual_ipaddress:
              - 10.1.0.26 dev eth0

{# Backup Host (low prio) #}
keepalived:
  configs:
    01_global_defs:
      sections:
        - comment: Global settings
          type: global_defs
          settings:
            notification_email:
              - hostmaster@example.net
            notification_email_from: root@{{ salt['grains.get']('fqdn') }}
            smtp_server: 127.0.0.1
            smtp_connect_timeout: 30
            router_id: id_TBD_TODO
    02_virtual_instances:
      sections:
        - comment: HTTP Software Repositories
          name: VI_1
          type: vrrp_instance
          settings:
            state: BACKUP
            smtp_alert: ''
            interface: eth0
            virtual_router_id: 51
            priority: 20
            advert_int: 1
            authentication:
              auth_type: PASS
              auth_pass: foobar
            virtual_ipaddress:
              - 10.1.0.26 dev eth0
