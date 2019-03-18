from lib.common import helpers


class Module:

    def __init__(self, mainMenu, params=[]):

        # Metadata info about the module, not modified during runtime
        self.info = {
            # Name for the module that will appear in module menus
            'Name': 'Get-ASRRules',

            # List of one or more authors for the module
            'Author': ['@Spacecow'],

            # More verbose multi-line description of the module
            'Description': ('Get definitions of Attack Surface Reduction rules that are enabled on the target host.',
                            'Requires Get-MpPreference cmdlet which is only present on Windows 10 (Powershell 5).'),

            # True if the module needs to run in the background
            'Background': False,

            # File extension to save the file as
            'OutputExtension': None,

            # True if the module needs admin rights to run
            'NeedsAdmin': False,

            # True if the method doesn't touch disk/is reasonably opsec safe
            'OpsecSafe': True,

            # The language for this module
            'Language': 'powershell',

            # The minimum PowerShell version needed for the module to run
            'MinLanguageVersion': '5',

            # List of any references/other comments
            'Comments': [
                'Based on the work of enigma0x3, all credit to him for the research.',
                'https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39'
                'https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-exploit-guard/attack-surface-reduction-exploit-guard'
            ]
        }

        # Any options needed by the module, settable during runtime
        self.options = {
            # Format:
            #   value_name : {description, required, default_value}
            'Agent': {
                # The 'Agent' option is the only one that MUST be in a module
                'Description':   'Agent to get enabled Attack Surface Reduction rules from.',
                'Required'   :   True,
                'Value'      :   ''
            }
        }

        # Save off a copy of the mainMenu object to access external
        #   functionality like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        # During instantiation, any settable option parameters are passed as
        #   an object set to the module and the options dictionary is
        #   automatically set. This is mostly in case options are passed on
        #   the command line.
        if params:
            for param in params:
                # Parameter format is [Name, Value]
                option, value = param
                if option in self.options:
                    self.options[option]['Value'] = value


    def generate(self, obfuscate=False, obfuscationCommand=""):
        script = """
Function Get-ASRRule
{
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

    Get-MpPreference | Select AttackSurfaceReductionRules_IDs | % {
        ForEach ($Rule in $Rules)
        {
            If ($_ -eq $Rule.GUID)
            {
                New-Object PSObject @{
                    "GUID"=$Rule.GUID;
                    "Description"=$Rule.Description
                }
            }
        }
    }
}
Function Get-ASRRule"""

        scriptEnd = ""

        # Add any arguments to the end execution of the script
        for option, values in self.options.iteritems():
            if option.lower() != "agent":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == "true":
                        # if we're just adding a switch
                        scriptEnd += " -" + str(option)
                    else:
                        scriptEnd += " -" + str(option) + " " + str(values['Value'])
        if obfuscate:
            scriptEnd = helpers.obfuscate(psScript=scriptEnd, installPath=self.mainMenu.installPath, obfuscationCommand=obfuscationCommand)
        script += scriptEnd
        return script
