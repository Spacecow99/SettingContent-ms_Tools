
Function Find-ASRRuleDescription()
{
<#

.SYNOPSIS
    Find the definition of the given Attack Surface Reduction rule.

.DESCRIPTION
    Compared the provided GUID to a list of Attack Surface Reduction rule GUIDs and if the provided GUID is found,
    return a PSObject containing the GUID and Description of the rule. GUIDs can be piped in from
    "Get-MpPreference | Select AttackSurfaceReductionRules_IDs".

.PARAMETER GUID
    Attack Surface Redunction rule GUID you wish to find the description for.

.EXAMPLE
    Find-ASRRuleDescription -GUID "{D3E037E1-3EB8-44C8-A917-57927947596D}"

.EXAMPLE
    Get-MpPreference | Select AttackSurfaceReductionRules_IDs | Find-ASRRuleDescription

.LINK
    https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-exploit-guard/attack-surface-reduction-exploit-guard
    https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39

.NOTES
    To get ASR rules enabled on the remote host, run "Get-MpPreference | Select AttackSurfaceReductionRules_IDs | ConvertTo-CSV" on client,
    convert with "(ConvertFrom-CSV).AttackSurfaceReductionRules_IDs" on local machine and pipe it in to the cmdlet.

#>
    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [String] $GUID
    )

    $Rules = @(
        @{"GUID"="{BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550}"; "Description"="Block executable content from email client and webmail."},
        @{"GUID"="{D4F940AB-401B-4EFC-AADC-AD5F3C50688A}"; "Description"="Block Office applications from creating child processes"},
        @{"GUID"="{3B576869-A4EC-4529-8536-B80A7769E899}"; "Description"="Block Office applications from creating executable content"},
        @{"GUID"="{75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84}"; "Description"="Block Office applications from injecting code into other processes"},
        @{"GUID"="{D3E037E1-3EB8-44C8-A917-57927947596D}"; "Description"="Block JavaScript or VBScript from launching downloaded executable content"},
        @{"GUID"="{5BEB7EFE-FD9A-4556-801D-275E5FFC04CC}"; "Description"="Block execution of potentially obfuscated scripts"},
        @{"GUID"="{92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B}"; "Description"="Block Win32 API calls from Office macro"},
        @{"GUID"="{01443614-cd74-433a-b99e-2ecdc07bfc25}"; "Description"="Block executable files from running unless they meet a prevalence, age, or trusted list criteria"},
        @{"GUID"="{c1db55ab-c21a-4637-bb3f-a12568109d35}"; "Description"="Use advanced protection against ransomware"},
        @{"GUID"="{9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2}"; "Description"="Block credential stealing from the Windows local security authority subsystem (lsass.exe)"},
        @{"GUID"="{d1e49aac-8f56-4280-b9ba-993a6d77406c}"; "Description"="Block process creations originating from PSExec and WMI commands"},
        @{"GUID"="{b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4}"; "Description"="Block untrusted and unsigned processes that run from USB"}
    )

    ForEach ($Rule in $Rules)
    {
        If ($GUID -eq $Rule.GUID)
        {
            New-Object PSObject @{
                "GUID"=$Rule.GUID;
                "Description"=$Rule.Description
            }
        }
    }
}
