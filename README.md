# salt-icinga-moaas

:wrench: Saltstack states to configure icinga agent for moaas monitoring.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-icinga-moaas.git salt/icinga-moaas
    
The states depend on their actual location in the state file tree, so naming `salt/icinga-moaas` is mandatory.

### Requires pillar

```sls
icinga:
  # username and password for access to the director API
  apiaccess: user:password
  # Base URL for icingaweb to access director API
  apiurl: "https://master.example.com/icingaweb2"
  # Hostname to connect to the icinga master
  masterhost: "master.example.com"
  # Name of the icinga master zone
  masterzone: "ip-...ec2.internal"

```

### Apply states

check pillar config:

    # salt 'myhost.example.com' pillar.items icinga
    myhost.example.com:
        ----------
        icinga:
            ----------
            apiaccess:
                cebe:*******
            apiurl:
                http://master.example.com/icingaweb2
            masterhost:
                master.example.com
            masterzone:
                ip-********.ec2.internal

apply state:

    # salt 'myhost.example.com' state.sls icinga-moaas


## Supported OSs

- Debian
  - 11, `bullseye` 
  - 10, `buster` 
  - 9, `stretch`
