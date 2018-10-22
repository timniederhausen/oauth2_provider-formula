{% from 'oauth2_proxy/map.jinja' import oauth2_proxy with context %}
{% from 'oauth2_proxy/macros.jinja' import sls_block with context %}

oauth2_proxy_bin:
  file.managed:
    - name: {{ oauth2_proxy.bin_path }}
    - owner: root
    - group: {{ oauth2_proxy.root_group }}
    - mode: 755
    {{ sls_block(oauth2_proxy.bin_file) | indent(4) }}

oauth2_proxy_user:
  user.present:
    - name: {{ oauth2_proxy.user }}
    - fullname: oauth2_proxy Owner
    - shell: /usr/sbin/nologin
    - home: {{ oauth2_proxy.workdir }}
    - system: true

oauth2_proxy_config:
  file.managed:
    - name: {{ oauth2_proxy.config_path }}
    - source: salt://oauth2_proxy/files/oauth2_proxy.cfg
    - owner: {{ oauth2_proxy.user }}
    - group: {{ oauth2_proxy.root_group }}
    - mode: 640
    - template: jinja
    - context:
        config: {{ oauth2_proxy.config | yaml }}

oauth2_proxy_workdir:
  file.directory:
    - name: {{ oauth2_proxy.workdir }}
    - owner: {{ oauth2_proxy.user }}
    - makedirs: true

{% if grains.os_family == 'FreeBSD' %}
oauth2_proxy_service_script:
  file.managed:
    - name: /usr/local/etc/rc.d/{{ oauth2_proxy.service }}
    - source: salt://oauth2_proxy/files/freebsd-rc.sh
    - template: jinja
    - mode: 755
    - context:
        fullname: {{ oauth2_proxy.service }}
        directory: {{ oauth2_proxy.workdir }}
        user: {{ oauth2_proxy.user | yaml_encode }}
        config: {{ oauth2_proxy.config_path | yaml_encode }}
        executable: {{ oauth2_proxy.bin_path }}
{% endif %}

{% set service_function = 'running' if oauth2_proxy.service_enabled else 'dead' %}
oauth2_proxy_service:
  service.{{ service_function }}:
    - name: {{ oauth2_proxy.service }}
    - enable: {{ oauth2_proxy.service_enabled }}
    - watch:
      - file: oauth2_proxy_bin
      - file: oauth2_proxy_config
    - require:
      - file: oauth2_proxy_bin
      - file: oauth2_proxy_config
      - user: oauth2_proxy_user
      - file: oauth2_proxy_workdir
{% if grains.os_family == 'FreeBSD' %}
      - file: oauth2_proxy_service_script
{% endif %}
