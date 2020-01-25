#$DebugPreference = "continue"
#$ErrorActionPreference = "continue"
$DebugPreference = "silentlycontinue"
$ErrorActionPreference = "silentlycontinue"




$IpadressADDS = "192.168.0.10"    # Mettre l'ip static du Server AD
$IpGatewayADDS = "192.168.0.1"    # Mettre la passerelle du Server AD ( ici celle de PF )



########## Parametre pour l'installation de la foret ##########
$CreateDnsDelegation = $false
$DomainName = "BP66.moche "
$NetbiosName = "BP66"
$NTDSPath = "D:\AD-DS\NTDS"
$LogPath = "E:\AD-DS\LOG"
$SysvolPath = "F:\AD-DS\SYSVOL"
$DomainMode = "Win2012R2"
$InstallDNS = $true
$ForestMode = "Win2012R2"
$NoRebootOnCompletion = $true

########## Parametre pour l'installation de la foret ##########
$dnsForwarder1 = "192.168.99.1"  # Si pas une IPv4 ne mettra pas de forwarder ( ici celle de l'afti )
$dnsForwarder2 = "192.168.99.2"  # Si pas une IPv4 ne mettra pas de forwarder ( ici celle de l'afti )


function initDisk () {
    param($numero,$lettre,$label)
    $Disk=Get-Disk $numero
    $statuDisk = $Disk.OperationalStatus
    if ($statuDisk -eq "Online")
    {         
        Clear-Disk -Number $numero -RemoveData 
    }    
    Set-Disk $numero -isOffline $false  
    Set-Disk $numero -isReadOnly $false 
    Initialize-Disk $numero -PartitionStyle GPT

    New-Partition -DiskNumber $numero -UseMaximumSize -DriveLetter $lettre | Format-Volume  -FileSystem NTFS -NewFileSystemLabel ($ComputerName + "-$label") | Out-Null 
    echo "#### Disque $lettre : initialiser: `t [OK]"
}







. .\msgbox.ps1



Clear-Host

echo "############ DEBUT DES VERIFICATION PRELEMINAIRE ############"
echo "####"

$nomPc = [system.environment]::MachineName
if ($nomPc -notlike "DC?-*"){
    $reponse= Show-Message -Message "Le nom du PC n'a pas été renommé. Actuellement : $nomPc`n`rContinuer ?" -Titre "Renommage du PC n'ont faite" -YesNo -IconAvertissement
    If ($reponse -eq 'No'){ 
        echo "#### Nommage PC `t`t`t`t [NOK]"
        Exit       
    }
    Show-Message -Message "C'est pas conseiller, mais allons y..." -Titre "Grosse erreur" -IconAvertissement        
}
echo "#### Nommage PC `t`t`t`t [OK]"
echo "#### Nom :  `t`t`t`t [OK]"


$Names = $nomPc


$reponse=$null
$Disk=Get-Disk
$nbDisk = $Disk.Count
if ($nbDisk -lt 3)    {
    $reponse= Show-Message -Message "Il n`'y a pas assez de disque pour faire les bonnes pratiques..`n`rContinuer ?" -Titre "$nbDisk/4 disques (OS/SYSVOL/LOG/NTFS)" -YesNo -IconAvertissement
    If ($reponse -eq 'No'){ 
        echo "#### Nombre de disque $nbDisk `t`t`t [NOK] "
        Exit       
    }
    Show-Message -Message "C'est pas conseiller, mais allons y..." -Titre "Grosse erreur" -IconAvertissement
}
echo "#### Nombre de disque $nbDisk `t`t`t [OK] "





$ComputerName = $nomPc
Set-Volume -DriveLetter C -NewFileSystemLabel ($ComputerName + '-00') 
$dvd = Get-WmiObject Win32_Volume -Filter 'DriveType = 5' 
If( $dvd -Ne $null ) { 
    $dvd.DriveLetter = "X:" 
    $dvd.Put() | Out-Null
    echo "#### CDROM en X: `t`t`t`t [OK]"
} 






initDisk -numero 1 -lettre D -label "LOG"
initDisk -numero 2 -lettre E -label "NTFS"
initDisk -numero 3 -lettre F -label "SYSVOL"

New-Item "D:\" -Name "AD-DS" -ItemType Directory -Force | Out-Null
New-Item "E:\" -Name "AD-DS" -ItemType Directory -Force | Out-Null
New-Item "F:\" -Name "AD-DS" -ItemType Directory -Force | Out-Null


echo "############################ FIN ############################"
pause
echo "############ DEBUT DE L`'INSTALLATION AD-DS ET DNS ###########"



########## Configuration de l'interface Ethernet0 en ip static ##########
New-NetIPAddress -InterfaceIndex 12 -IPAddress $IpadressADDS -PrefixLength 24 -DefaultGateway $IpGatewayADDS -AddressFamily IPv4
Set-NetIPInterface -InterfaceIndex 12 -Dhcp Disabled
Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses $IpadressADDS






########## Installation de la fonctionnalité AD-DS ##########
Install-WindowsFeature AD-Domain-Services
exit
########## Installation de la Foret  ##########
Install-ADDSForest -CreateDnsDelegation:$CreateDnsDelegation -DomainName $DomainName -DatabasePath $NTDSPath -DomainMode $DomainMode -DomainNetbiosName $NetbiosName -ForestMode $ForestMode -InstallDNS:$InstallDNS -LogPath $LogPath -NoRebootOnCompletion:$NoRebootOnCompletion -SysvolPath $SysvolPath  | Out-Null


Restart-Computer -ComputerName $Names
