#$DebugPreference = "continue"
#$ErrorActionPreference = "continue"
$DebugPreference = "silentlycontinue"
$ErrorActionPreference = "silentlycontinue"


if ($dnsForwarder1 -like "*.*.*.*"){
    Add-DnsServerForwarder -IPAddress $dnsForwarder1 -PassThru
}
if ($dnsForwarder2 -like "*.*.*.*"){
    Add-DnsServerForwarder -IPAddress $dnsForwarder2 -PassThru
}


$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Disque D - NTDS.lnk")
# Cible du raccourci
$Shortcut.TargetPath = "D:\AD-DS\NTDS"
# Dossier cible
$Shortcut.WorkingDirectory = "D:\AD-DS\NTDS";
# Chemin vers l'icône 
Invoke-WebRequest -Uri "http://download.seaicons.com/download/i44147/arrioch/blawb/arrioch-blawb-phonebook.ico" -OutFile "C:\temp\myIcontfs.ico"
$Shortcut.IconLocation = "c:\temp\myIcontfs.ico, 0";
$Shortcut.Save()

$Shell = $null
$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Disque E - Logs.lnk")
# Cible du raccourci
$Shortcut.TargetPath = "E:\AD-DS\LOG";
# Dossier cible
$Shortcut.WorkingDirectory = "E:\AD-DS\LOG"
# Chemin vers l'icône 
Invoke-WebRequest -Uri "http://download.seaicons.com/download/i83612/pelfusion/flat-file-type/pelfusion-flat-file-type-log.ico" -OutFile "C:\temp\myIcolog.ico"
$Shortcut.IconLocation = "c:\temp\myIcolog.ico, 0";
$Shortcut.Save()

$Shell = $null
$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Disque F - Sysvol.lnk")
# Cible du raccourci
$Shortcut.TargetPath = "F:\AD-DS\SYSVOL"
# Dossier cible
$Shortcut.WorkingDirectory = "F:\AD-DS\SYSVOL"
# Chemin vers l'icône 
Invoke-WebRequest -Uri "https://icon-icons.com/descargaimagen.php?id=103331&root=1495/ICO/512/&file=systemconfigsamba_103331.ico" -OutFile "C:\temp\myIcoSysvol.ico"
$Shortcut.IconLocation = "c:\temp\myIcoSysvol.ico, 0";
$Shortcut.Save()