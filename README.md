# windows-ansible-modules
Set of modules to extend Ansible for Windows



# win_cmdlet:

 BvZ Todo test in  /usr/lib/python3/dist-packages/ansible/modules/windows
 sudo cp /mnt/c/GIT/ansible.windows/plugins/modules/win_cmdlet.p* /usr/lib/python3/dist-packages/ansible/modules/windows
 ansible-doc -t module win_cmdlet

  Test the module interactively:
  To Set DnsClient  Connection specific suffix, via Get/Set-DnsClient
```
ansible myserver1.domain.local -m win_cmdlet -a "cmdletnoun=DnsClient additionalparams='-InterfaceIndex 20' parameter='ConnectionSpecificSuffix' value='domain.local'"
```

Test via runbook:
```
ansible-playbook  ansible/playbook/test.cmdlet.yml -i yourinventory -l myserver1.domain.local -vv
```

Where test.cmdlet.yml  consists of:
```yaml
---
- name: testing ansible my own cmdlet module
hosts: Windows
tasks:
- name: echo a message
    debug: msg="this is working"
- name: ping
    win_ping:

- name: Set DNS ConnectionSpecificSuffix for adapter 20 to a fixed string.
    win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 20'
    parameter: 'ConnectionSpecificSuffix'
    value: 'domains.local'

- name: Set DNS UseSuffixWhenRegistering for adapter 20
    win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 20'
    parameter: 'UseSuffixWhenRegistering'
    value: 'False'
#     type: bool
- name: Set DNS RegisterThisConnectionsAddress for adapter 20
    win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 20'
    parameter: RegisterThisConnectionsAddress
    value: False
#     type: bool

- name: Set FileShare property
    win_cmdlet:
    cmdletnoun: FileShare
    additionalparams: '-Name "Admin$"'
    parameter: Description
    value: Remote admin

- name: Set WUSettings (from PSWindowsUpdate module) Targetgroup
    win_cmdlet:
    cmdletnoun: WUSettings
    additionalparams: '-Confirm:$False'
    parameter: 'TargetGroup'
    value: 'LNGUpdates'
...
```

TODO:
  win_cmdlet:
  * $module.Diff.before  and after: check if syntax used is correct
  * $module.Results   gives too much output (debug output) see if some debug output can be sent via the $module
  * Module currently only supports Get- and Set-  where both must have the same input params. Some cmdlets  have Set-  with -InputObject.  Maybe we can update the retrieved object, and send that to Set-
  * Module currently only supports Get- and Set- cmdlets. Sometimes there may be a need for Get- and New-
