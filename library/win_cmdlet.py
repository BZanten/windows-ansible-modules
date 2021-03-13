#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2021, Ben van Zanten (@BZanten)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {'metadata_version': '0.4',
                    'status': ['preview']}

DOCUMENTATION = r'''
---

module:  win_cmdlet

short_description: Run any generic PowerShell cmdlet that supports Get- and Set-, without having to create multiple tasks for that

description:
- There are a large number of PowerShell modules available, and new modules and cmdlets can be easily added from the different repositories on the web.
- Creating a Ansible modules to cope with each and every CmdLet in all these modules will become a daunting task.
- For Simple PowerShell cmdlets that supports Get-cmdlet  and Set-cmdlet  (in the future release also New-cmdlet) we can use this generic module to call a cmdlet to set a parameter to a value
- This release requires the property names returned from the cmdlet, to match the parameter to set/get it.  For instance
  Get-ADUser -Filter C(Filtername) , the returned object has Property 'GivenName'  that can be 'Set'  using  Set-ADUser -Filter C(Filtername) -Givenname 'Value'
  Since in the case of ADUser  the GivenName is both a property of a returned object, and a parameter on the 'Set-ADUser' cmdlet, this can be easily set in this module.
options:
  cmdletnoun:
    description:
    - The noun of the Cmdlet to be ran. The module will run Get-I(cmdletnoun) to retrieve the property
    type: str
    required: yes
  additionalparams:
    description:
    - The additional parameters to feed the cmdlet to make sure it finds a single object.
    - Note both the Get-C(cmdletnoun)  cmdlet AND the Set-C(cmdletnoun) cmdlet should support this same parameter(s) to uniquely identify the object to change.
    type: str
    required: no
  parameter:
    description:
    - This is both the name of the object property that should be retrieved from Get-I(cmdletnoun)  AND the name of the argument for Set-I(cmdletnoun) -I(parameter) to set
    type: str
    required: yes
  value:
    description:
    - The value that should be present when C(Get)ting the parameter name, or that is set when C(Set)ting the value
    type: str
    required: yes

notes:
- This module is using built-in PowerShell cmdlets, where there is both a Get- variant, for getting properties,
  AND a Set- variant to set the property (where currently the Set- cmdlet should support an argumentname that matches the object property just retrieved)
- The Get-  command should return 1 object (not more, not less)
- The Object should have a property that matches an argument on the Set- cmdlet
- This module broadcasts change events.
- This module supports check mode via a -WhatIf implementation
- In the return, C(before_value) and C(value) will be set to the last values.
seealso:
- module: ansible.windows.win_path

author:
- Ben van Zanten (@BZanten)
'''

EXAMPLES = r'''
- name: Set the DNS suffix for adapter 13 to value: 'domain.local'
  win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 13'
    parameter: 'ConnectionSpecificSuffix'
    value: 'domain.local'

- name: Set DNS UseSuffixWhenRegistering for adapter 20 to $True
  win_cmdlet:
    cmdletnoun: DnsClient
    additionalparams: '-InterfaceIndex 20'
    parameter: 'UseSuffixWhenRegistering'
    value: $True

- name: Set for VM 'TestPC', its automaticStartAction to 'StartIfRunning'
  win_cmdlet:
    cmdletnoun: VM
    additionalparams: '-Name "testpc"'
    parameter: 'AutomaticStartAction'
    value: 'StartIfRunning'

  # The Set-WUSettings cmdlet asks for confirmation, so suppress that
- name: Set WUSettings (from PSWindowsUpdate module) Targetgroup to 'Test machines'
  win_cmdlet:
    cmdletnoun: WUSettings
    additionalparams: '-Confirm:$False'
    parameter: 'TargetGroup'
    value: 'Test Machines'

'''

RETURN = r'''
before_value:
  description: The value of the parameter before a change, this is null if it didn't exist
  returned: always
  type: str
  sample: True
value:
  description: the value the parameter has been set to
  returned: always
  type: str
  sample: False

'''
