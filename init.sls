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

# add user nagios to group adm to be able to read log files
adduser nagios adm:
  cmd.run:
    - unless: 'groups nagios |grep "\badm\b"'
    - require:
      - cmd: icinga_setup

icinga_service:
  service.running:
    - enable: True
    - name: icinga2
    - watch:
      - cmd: icinga_setup
      - cmd: adduser nagios adm
      - file: /etc/icinga2/zones.conf
      - file: /etc/icinga2/conf.d

# install plugins
/usr/lib/nagios/plugins/check_cpu:
  file.managed:
    - source: https://s3.dualstack.us-east-1.amazonaws.com/monitoring-plugins/Linux/check_cpu
    - source_hash: sha256=107fe41e65915de0817cbdc4399f2767add721cc4abffe2827d37d65dc8fad51
    - mode: '0755'

/usr/lib/nagios/plugins/check_linux_memory:
  file.managed:
    - source: https://s3.dualstack.us-east-1.amazonaws.com/monitoring-plugins/Linux/check_linux_memory
    - source_hash: sha256=d21e46c68e9bfd665a04929a68ddfdc9e6bf2bae675768de209494b9fb86aa21
    - mode: '0755'

/usr/lib/nagios/plugins/check_logfiles:
  file.managed:
    - source: https://s3.dualstack.us-east-1.amazonaws.com/monitoring-plugins/Linux/check_logfiles
    - source_hash: sha256=9b4fcbc1634179d7bd7adcf77a56b6bf3603eb82c1ff133a8962591f0e1130a1
    - mode: '0755'

/usr/lib/nagios/plugins/check_md_raid.sh:
  file.managed:
#    - source: https://exchange.icinga.com/exchange/check_md_raid/files/661/check_md_raid.sh
    - source: salt://icinga-moaas/plugins/check_md_raid.sh
    - source_hash: sha256=d3e79c66349d0f0b4ef30d3b1ba96075052a806621c16c48f910a28999ff8a59
    - mode: '0755'

python3-nagiosplugin:
  pkg.installed
python3-gi:
  pkg.installed

{% if grains['oscodename'] == 'buster' %}
# this file does not contain the logfile check in buster, but works fine on bullseye 
/usr/share/icinga2/include/plugins-contrib.d/logmanagement.conf:
  file.managed:
    - source: salt://icinga-moaas/usr/share/icinga2/include/plugins-contrib.d/logmanagement.conf
    - require:
      - cmd: icinga_setup
    - watch_in:
      - service: icinga_service
{% endif %}


/usr/lib/nagios/plugins/check-systemd-service:
  file.managed:
    - source: https://raw.githubusercontent.com/pengutronix/monitoring-check-systemd-service/b0482f800d788beb36fee7c63f48b35fcd2fc2e4/check-systemd-service
    - source_hash: sha256=5c0c21adec8acc8f0298afdf1425282fa44ad2430f832786ba144dbe60f9970f
    - mode: '0755'

/usr/lib/nagios/plugins/check_galera_cluster:
  file.managed:
    - source: https://raw.githubusercontent.com/fridim/nagios-plugin-check_galera_cluster/aa17849014180c2025beb6a36e268f6f54981744/check_galera_cluster
    - source_hash: sha256=dc6760969ec31fc10fb745f0c32e6c0bcea3926d721b60bc190d1b8b27aac644
    - mode: '0755'
