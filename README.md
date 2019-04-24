# salt-icinga-moaas

:wrench: Saltstack states to configure icinga agent for moaas monitoring.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-icinga-moaas.git salt/icinga-moaas
    
The states depend on their actual location in the state file tree, so naming `salt/icinga-moaas` is mandatory.

## Requires pillar

... TODO

## Supported OSs

- Debian
  - 9, `stretch`
