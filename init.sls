icinga2:
  pkg.installed

icinga_packages:
  pkg.installed:
    - pkgs:
       - monitoring-plugins
       - bc
       - curl
       - hostname
       - ca-certificates
    - require:
      - pkg: icinga2

/opt/setup_icinga_client.sh:
  file.managed:
    - source: salt://icinga-moaas/setup_icinga_client.sh
    - mode: '0700'
    - user: root
    - group: root
    - template: jinja

/etc/icinga2/conf.d:
  file.recurse:
    - source: salt://icinga-moaas/etc/icinga2/conf.d
    - clean: True
    - dir_mode: '0755'
    - file_mode: '0644'
    - template: jinja

/etc/icinga2/zones.conf:
  file.managed:
    - source: salt://icinga-moaas/etc/icinga2/zones.conf
    - template: jinja

/etc/icinga2/icinga2.conf:
  file.managed:
    - source: salt://icinga-moaas/etc/icinga2/icinga2.conf
    - template: jinja

icinga_setup:
  cmd.run:
    - name: /bin/bash /opt/setup_icinga_client.sh || (rm /opt/setup_icinga_client.sh; exit 1)
    - onchanges:
      - file: /opt/setup_icinga_client.sh
      - file: /etc/icinga2/zones.conf
      - file: /etc/icinga2/icinga2.conf
      - file: /etc/icinga2/conf.d
    - require:
      - pkg: icinga2
      - pkg: icinga_packages

icinga_service:
  service.running:
    - enable: True
    - name: icinga2
    - watch:
      - cmd: icinga_setup
      - file: /etc/icinga2/zones.conf
      - file: /etc/icinga2/conf.d

# install plugins
/usr/lib/nagios/plugins/check_cpu:
  file.managed:
    - source: https://s3.amazonaws.com/monitoring-plugins/Linux/check_cpu
    - source_hash: sha256=107fe41e65915de0817cbdc4399f2767add721cc4abffe2827d37d65dc8fad51
    - mode: '0755'

/usr/lib/nagios/plugins/check_linux_memory:
  file.managed:
    - source: https://s3.amazonaws.com/monitoring-plugins/Linux/check_linux_memory
    - source_hash: sha256=d21e46c68e9bfd665a04929a68ddfdc9e6bf2bae675768de209494b9fb86aa21
    - mode: '0755'

/usr/lib/nagios/plugins/check_logfiles:
  file.managed:
    - source: https://s3.amazonaws.com/monitoring-plugins/Linux/check_logfiles
    - source_hash: sha256=9b4fcbc1634179d7bd7adcf77a56b6bf3603eb82c1ff133a8962591f0e1130a1
    - mode: '0755'

/usr/lib/nagios/plugins/check_md_raid.sh:
  file.managed:
    - source: https://exchange.icinga.com/exchange/check_md_raid/files/661/check_md_raid.sh
    - source_hash: sha256=d3e79c66349d0f0b4ef30d3b1ba96075052a806621c16c48f910a28999ff8a59
    - mode: '0755'
