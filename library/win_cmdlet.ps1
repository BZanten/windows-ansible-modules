#!powershell

# Copyright: (c) 2021, Ben van Zanten (@BZanten)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        cmdletnoun = @{ type = "str"; required = $true }
        additionalparams = @{ type = "str" }
        parameter = @{ type = "str"; required = $true }
        type = @{
            type = 'str'
            default = 'auto'
            choices = 'auto', 'string', 'Char', 'bool', 'boolean', 'byte', 'sbyte', 'Int16', 'Int32', 'Int64', 'UInt16', 'UInt32', 'UInt64', 'Single', 'Double', 'Decimal', 'DateTime', 'Base64String', 'Base64CharArray'
            aliases = 'datatype'
        }
        value = @{ type = "str"; required = $true }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Function ConvertTo-Type {
    <#
    .Synopsis
      Converts strings into other data types
    .Description
      Converts strings into other data types.
      When comparing values, they sometimes need to be of the same type: f.i. when comparing boolean $False with string $False we get unexpected results.
      This function converts a string into another datatype, but then again also outputs the string version of that output since the Invoke-Expression command (used later) only 
      accepts a string and in that case a 'True' value should then again be passed as a '$True' value.
    #>
    PARAM (
        $Value,
        $Type
    )

    $RetVal = $Null
    $EnUsCulture = New-Object System.Globalization.CultureInfo("en-US")
    switch ($Type) {
        'string'          { $RetVal = @{ 'Value' = [System.Convert]::ToString($Value) ; 'ValueString' = $Value } }
        'Char'            { $RetVal = @{ 'Value' = [System.Convert]::ToChar($Value) ; 'ValueString' = $Value } }
        'bool'            { $Value = [Ansible.Basic.AnsibleModule]::ParseBool($Value)
                            $RetVal = @{ 'Value' = [System.Convert]::ToBoolean(($Value -replace '\$',''),$EnUsCulture) ; 'ValueString' = '$' + ([System.Convert]::ToBoolean(($Value -replace '\$',''),$EnUsCulture)).ToString() }
                          }
        'boolean'         { $Value = [Ansible.Basic.AnsibleModule]::ParseBool($Value)
                            $RetVal = @{ 'Value' = [System.Convert]::ToBoolean(($Value -replace '\$',''),$EnUsCulture) ; 'ValueString' = '$' + ([System.Convert]::ToBoolean(($Value -replace '\$',''),$EnUsCulture)).ToString() }
                          }
        'byte'            { $RetVal = @{ 'Value' = [System.Convert]::ToByte($Value) ; 'ValueString' = $Value } }
        'sbyte'           { $RetVal = @{ 'Value' = [System.Convert]::ToSByte($Value) ; 'ValueString' = $Value } }
        'Int16'           { $RetVal = @{ 'Value' = [System.Convert]::ToInt16($Value) ; 'ValueString' = $Value } }
        'Int32'           { $RetVal = @{ 'Value' = [System.Convert]::ToInt32($Value) ; 'ValueString' = $Value } }
        'Int64'           { $RetVal = @{ 'Value' = [System.Convert]::ToInt64($Value) ; 'ValueString' = $Value } }
        'UInt16'          { $RetVal = @{ 'Value' = [System.Convert]::ToUInt16($Value) ; 'ValueString' = $Value } }
        'UInt32'          { $RetVal = @{ 'Value' = [System.Convert]::ToUInt32($Value) ; 'ValueString' = $Value } }
        'UInt64'          { $RetVal = @{ 'Value' = [System.Convert]::ToUInt64($Value) ; 'ValueString' = $Value } }
        'Single'          { $RetVal = @{ 'Value' = [System.Convert]::ToSingle($Value) ; 'ValueString' = $Value } }
        'Double'          { $RetVal = @{ 'Value' = [System.Convert]::ToDouble($Value) ; 'ValueString' = $Value } }
        'Decimal'         { $RetVal = @{ 'Value' = [System.Convert]::ToDecimal($Value) ; 'ValueString' = $Value } }
        'DateTime'        { $RetVal = @{ 'Value' = [System.Convert]::ToDateTime($Value,$EnUsCulture) ; 'ValueString' = $Value } }
        'Base64String'    { $RetVal = @{ 'Value' = [System.Convert]::ToBase64String($Value) ; 'ValueString' = $Value } }
        'Base64CharArray' { $RetVal = @{ 'Value' = [System.Convert]::ToBase64CharArray($Value) ; 'ValueString' = $Value } }
        default           { $RetVal = @{ 'Value' = [System.Convert]::ToString($Value) ; 'ValueString' = $Value } }
    }

    # Return the result: object with Properties: 'Value' of type 'Type'  AND 'ValueString' of type 'String'
    Write-Output $RetVal
}


Set-StrictMode -Version 2.0

# Note: Parameter 'Value'  can only be determined later, when the 'type' is known.
#       For type='auto' we first need to retrieve an object, then determine the type of the property.
$CmdLetNoun       = $module.Params.cmdletnoun
$AdditionalParams = $module.Params.additionalparams
$Parameter        = $module.Params.parameter
$Type             = $module.Params.type

$ret = @{
    changed = $false
    after = $Null
    before = $Null
}

# supports_check_mode = $true  -WhatIf:$($module.CheckMode)  -> $module.CheckMode is either 'false' or 'true' this also needs to be converted to String. (add a $)
$WhatIfMode =  ConvertTo-Type -Value $module.CheckMode -Type 'bool'


$CmdLetToRunGet = "Get-{0} {1}" -f ($CmdLetNoun, $AdditionalParams)
$CmdLetToRunSet = "<notused>"
$module.Debug($CmdLetToRunGet)
$module.LogEvent($CmdLetToRunGet,'Information',$True)
Try {
    $CurResult = Invoke-Expression -Command $CmdLetToRunGet 2>&1
} catch {
    $module.LogEvent($CmdLetToRunGet + " -> " + $_.ToString(),'Error',$True)
    $module.FailJson('Error running ' + $CmdLetToRunGet, $_)
}
if ($CurResult) {
    if ($CurResult | Get-Member -Name Exception) {
        $module.LogEvent($er.Exception.ToString(),'Error',$True)
        $module.FailJson($er.Exception.ToString())
    } else {
        if ($CurResult -is [Object[]]) {
            $module.LogEvent($CmdLetToRunGet + ' -> Multiple objects where retrieved. Make sure to use the additionalparams argument to specify arguments to only select a single object','Error',$True)
            $module.FailJson('Multiple objects where retrieved. Make sure to use the additionalparams argument to specify arguments to only select a single object')
        } else {
            # When we want to set a property to a value, we may need to know the type of value to set (string, bool, date etc).
            # This can be determined when we retrieved the object, then look at the type of that property
            # Now we can determine the type of the property, and convert the value to that type and to string
            $ParameterObject = $CurResult.psobject.members | Where-Object { $_.Name -eq $Parameter }
            if ($Type -eq 'auto') {
                if ($ParameterObject) {
                    $Type = ($CurResult.psobject.members | Where-Object { $_.Name -eq $Parameter } | Select-Object -Property TypeNameOfValue).TypeNameOfValue
                } else {
                    $module.FailJson([string]::Format('There is no property {0} on this object', $Parameter))
                }
            }
            $CurValue = ConvertTo-Type -Value $CurResult.$Parameter -Type $Type
            $Value    = ConvertTo-Type -Value $module.Params.value -Type $Type
            $ret.before = $CurValue
            #  Make sure to compare the 'real' values against each other. Now they are of the same datatype.
            if ($CurValue.Value -ne $Value.Value) {
                $module.Debug("Changing parameter $Parameter from $($CurValue.ValueString) to $($Value.ValueString)")

                # Make sure the command Set-XXX does contain a parameter -$Parameter
                if ((Get-Command ('Set-' + $CmdLetNoun)).Parameters.Keys -contains $Parameter) {
                    # Create a Set-XXX command and execute it.
                    $CmdLetToRunSet = "Set-{0} {1} -$Parameter $($Value.ValueString) -WhatIf:{2}" -f ($CmdLetNoun, $AdditionalParams,$WhatIfMode.ValueString)
                    $module.Debug( $CmdLetToRunSet )
                    $module.LogEvent($CmdLetToRunSet,'Information',$True)
                    Try {
                        $er = (Invoke-Expression $CmdLetToRunSet) 2>&1
                        $ret.changed = $True
                        $ret.after   = $Value
                    } catch {
                        $module.LogEvent($CmdLetToRunGet + " -> " + $_.ToString(),'Error',$True)
                        $module.FailJson('Error running ' + $CmdLetToRunSet, $_)
                    }
                    if ($er) {
                        if ($er | Get-Member -Name Exception) {
                            $module.LogEvent($er.Exception.ToString(),'Error',$True)
                            $module.FailJson($er.Exception.ToString())
                            $ret.changed = $False
                            $ret.after   = $CurValue
                        }
                    }
                } else {
                    $module.LogEvent('PowerShell cmdlet Set-' + $CmdLetToRunGet + ' does NOT support a parameter called:' + $Parameter,'Error',$True)
                    $module.FailJson('PowerShell cmdlet Set-' + $CmdLetToRunGet + ' does NOT support a parameter called:' + $Parameter)
                }
            } else {
                $module.Debug( "Parameter $Parameter is already $($CurResult.$Parameter)" )
                $ret.before = $CurValue
                $ret.after   = $Value
            }
        }
    }
} else {
    $module.LogEvent('No object was found','Error',$True)
    $module.FailJson('No object was found')
}

# Return information
$module.Diff.before = @{ $CmdLetNoun = @{} }
if ($ret.before.ValueString) {
    $module.Diff.before.$CmdLetNoun.$Parameter = $ret.before.Value
}
$module.Diff.after = @{ $CmdLetNoun = @{} }
if ($ret.after.ValueString) {
    $module.Diff.after.$CmdLetNoun.$Parameter = $ret.after.Value
}

$module.Result.changed = $ret.changed
$module.Result.before_value = $ret.before.Value
$module.Result.value = $ret.after.Value
$module.Result.type = $Type

$module.ExitJson()
