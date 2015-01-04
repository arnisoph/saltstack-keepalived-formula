#!jinja|yaml

{% from "keepalived/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('keepalived:lookup')) %}


keepalived:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs|default(['keepalived']) }}
  service:
    - running
    - name: {{ datamap.service.name|default('keepalived') }}
    - enable: {{ datamap.service.enable|default(True) }}
    {# TODO: service doesn't have a status command. Is this Debian specifc? #}
    - sig: {{ datamap.service.signame }}
    - require:
      - pkg: keepalived

{% if 'keepalived_conf' in datamap.config.manage|default([]) %}
keepalived_conf:
  file:
    - managed
    - name: {{ datamap.config.keepalived_conf.path|default('/etc/keepalived/keepalived.conf') }}
    - mode: {{ datamap.config.keepalived_conf.mode|default('644') }}
    - user: {{ datamap.config.keepalived_conf.user|default('root') }}
    - group: {{ datamap.config.keepalived_conf.group|default('root') }}
    - contents: |
        include /etc/keepalived/conf.d/*.conf
    - watch_in:
      - service: keepalived
{% endif %}

{% set configs = salt['pillar.get']('keepalived:configs', {}).items() -%}

{% for k, v in configs %}
{{ k }}:
  file:
    - managed
    - name: {{ datamap.config.configs.path_prefix|default('/etc/keepalived/conf.d') }}/{{ k }}.conf
    - source: {{ datamap.config.configs.template_path|default('salt://keepalived/files/configs') }}
    - template: {{ datamap.config.configs.template_renderer|default('jinja') }}
    - makedirs: {{ datamap.config.configs.makedir|default(True) }}
    - mode: {{ datamap.config.configs.mode|default('644') }}
    - user: {{ datamap.config.configs.user|default('root') }}
    - group: {{ datamap.config.configs.group|default('root') }}
    - context:
      config: {{ k }}
    - watch_in:
      - service: keepalived
{% endfor %}
