# salt-icinga-moaas

:wrench: Saltstack states to configure icinga agent for moaas monitoring.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-icinga-moaas.git salt/icinga-moaas
    
The states depend on their actual location in the state file tree, so naming `salt/icinga-moaas` is mandatory.

## Requires pillar

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

## Supported OSs

- Debian
  - 9, `stretch`
