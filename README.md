# windows-ansible-modules
Set of modules to extend Ansible for Windows



# win_cmdlet:

Ansible has a number of windows modules, but still there is a lot more PowerShell commands then there are Ansible modules.
If you want to use the idempotency of Ansible while using PowerShell native commands when there is no Ansible Module, you end up with an elaborate set of shell commands, first 'get'ting information, storing it in a return var, then (if value is not correct) taking action using a new set of shell commands to update some content.

I found out a number of PowerShell have similar Get-XXX commands where you can get an object with attributes, then use a similar Set-XXX command to update the target with a new parameter value.
So I wrote a module, just to learn Ansible modules, for this task.
The module will take the Noun as argument, and optional additional parameters, then try to set it, with the following constraints:
* the Verb-Noun in PowerShell is used, both the Get- and the Set- cmdlets must use the same Noun
* the Get-Noun  command should yield a single object, optionally use the additionalparams argument on this module to add additional params to the PowerShell cmdlet to make it yield a sinble object. In the example below -InterfaceIndex 20  will make sure only 1 interface is returned when retrieving DNS Client settings.
* a single parameter can be changed, but the retrieved object must have an attribute that matches an argument in the Set- cmdlet. For instance: Get-DnsClient  -InterfaceIndex 20   will yield a single Interface object with multiple attributes; its 'ConnectionSpecificSuffix' attribute value can be set to another value using 'Set-DnsClient -InterfaceIndex 20 -ConnectionSpecificSuffix 'mydomain.local'. If the Set- cmdlet has no argument that matches the name of an attribute on the Get object, this module won't work.

This check-and-set is now performed in a single module using the syntax:
```
- name: Set DNS ConnectionSpecificSuffix for adapter 20 to a fixed string.
    win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 20'
    parameter: 'ConnectionSpecificSuffix'
    value: 'domains.local'
```

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

 BvZ Todo test in  /usr/lib/python3/dist-packages/ansible/modules/windows
 sudo cp /mnt/c/GIT/ansible.windows/plugins/modules/win_cmdlet.p* /usr/lib/python3/dist-packages/ansible/modules/windows
 ansible-doc -t module win_cmdlet

