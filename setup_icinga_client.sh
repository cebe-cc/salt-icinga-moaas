#!/bin/bash

#
# Icinga API user needs permissions (configure in roles):
#
# - module/director
# - director/api
# - director/deploy
# - director/hosts
#
#
APIACCESS="{{ pillar.icinga.apiaccess }}"
APIURL="{{ pillar.icinga.apiurl }}"
MASTERHOST="{{ pillar.icinga.masterhost }}"
MASTERZONE="{{ pillar.icinga.masterzone }}"
host="{{ grains.id }}"
i2user='nagios'
os="Linux"
osfamily="Debian"

zone="{ \
	\"object_name\": \"${host}\", \
	\"object_type\": \"object\", \
	\"parent\": \"${MASTERZONE}\" \
}"

endpoint="{ \
	\"object_name\": \"${host}\", \
	\"object_type\": \"object\", \
	\"zone\": \"${host}\" \
}"

self="{ \
	\"address\": \"$(dig +noall +answer "${host}" A |awk '{print $5}')\", \
	\"address6\": \"$(dig +noall +answer "${host}" AAAA |awk '{print $5}')\", \
	\"display_name\": \"${host}\", \
	\"imports\": [ \"BaseClusterzone\"], \
	\"object_name\": \"${host}\", \
	\"object_type\": \"object\", \
	\"accept_config\": true, \
	\"master_should_connect\": false, \
	\"has_agent\": true, \
	\"vars\": { \
		\"os\": \"${os}\" \
	} \
}"

echo "creating zone: $zone"
curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/zone -X PUT -d "$zone" || \
  curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/zone?name=${host} -X POST -d "$zone" || exit 1
echo "done."

echo "creating host: $self"
curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/host -X PUT -d "$self" || \
  curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/host?name=${host} -X POST -d "$self" || exit 1
echo "done."

echo "creating endpoint: $endpoint"
curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/endpoint -X PUT -d "$endpoint" || \
  curl -s -S -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/endpoint?name=${host} -X POST -d "$endpoint" || exit 1
echo "done."


sleep 3

ticket=$(curl -s -f -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/host/ticket?name=${host} -X GET)
ret=$?
if [ $ret -ne 0 ]; then exit 1; fi

ICINGA_PKI_DIR=/etc/icinga2/pki
ICINGA_USER=$i2user
mkdir -p $ICINGA_PKI_DIR
chown $ICINGA_USER $ICINGA_PKI_DIR


echo "icinga2 pki new-cert"
icinga2 pki new-cert --cn ${host} \
	--key $ICINGA_PKI_DIR/${host}.key \
	--cert $ICINGA_PKI_DIR/${host}.crt
if [ $? -ne 0 ]; then exit 1; fi

echo "icinga2 pki save-cert"
icinga2 pki save-cert --key $ICINGA_PKI_DIR/${host}.key \
	--trustedcert $ICINGA_PKI_DIR/trusted-master.crt \
	--host $MASTERHOST
if [ $? -ne 0 ]; then exit 1; fi

echo "icinga2 pki request, with ticket '$ticket'"
icinga2 pki request --host $MASTERHOST \
	--port 5665 \
	--ticket $(echo $ticket | tr -d '"') \
	--key $ICINGA_PKI_DIR/${host}.key \
	--cert $ICINGA_PKI_DIR/${host}.crt \
	--trustedcert $ICINGA_PKI_DIR/trusted-master.crt \
	--ca $ICINGA_PKI_DIR/ca.crt
if [ $? -ne 0 ]; then exit 1; fi

curl -s -S -f -u "$APIACCESS" -H "Accept: application/json" $APIURL/director/config/deploy -X POST || exit 1

