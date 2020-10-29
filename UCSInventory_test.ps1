# Collect Inventory for CAG Cisco UCS Blade Servers
# Created by zmp0167    02\26\2020
# I just changed this file

# Load Cisco UCS PowerTools module
'D:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\startucsps.ps1'

# Allow Multiple UCS Domain logins
Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true

#Get Creds
#Enter UCS credentials
$cred = Get-Credential -Message "Enter UCSM Credentials (Username format: ucs-cag\zID)"

$credflex = Get-Credential -Message "Enter Credentials for Sexy Flexy"

#Connect to CAG UCS Domains
Write-Output ""
Write-Output "UCS BlockBA"
connect-ucs blockba -credential $cred
Write-Output "UCS BlockBE"
connect-ucs blockbe -credential $cred
Write-Output "UCS BlockCA"
connect-ucs blockca -credential $cred
Write-Output "UCS BlockCB"
connect-ucs blockcb -credential $cred
Write-Output "UCS BlockCC"
connect-ucs blockcc -credential $cred
Write-Output "Domain CHI-HXA"
connect-ucs chi-hxa -credential $cred
Write-Output "Domain CHI_HXB"
connect-ucs chi-hxb -credential $cred
Write-Output "Pinnacle UCS Block"
connect-ucs 10.40.40.80 -credential $credflex
Write-output "Sexy Flexy"
connect-ucs sexyflexy -credential $credflex

#$bladeData=get-ucsblade |Select-Object Ucs, Dn, Serial, NumOfCpus, NumOfCores, TotalMemory, AvailableMemory, MemorySpeed, Model, MfgTime, OperState, AssignedToDn

#$serverData=get-ucsserver |Select-Object Ucs, Dn, Serial, Model, MfgTime, NumOfCpus, NumOfCores, TotalMemory, AvailableMemory, MemorySpeed, OperState, AssignedToDn

#$logFile="\\vnasfil02\scratch$\zmp0167\UCS Inventory\CAGUCSinv-$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$servlogFile="\\cepemcnt01\software\scripts\powershell\UCS\CAGUCS-Server-inv-$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$chassisLogFile="\\cepemcnt01\software\scripts\powershell\UCS\CAGUCS-Chassis-inv-$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$fiLogFile="\\cepemcnt01\software\scripts\powershell\UCS\CAGUCS-FI-inv-$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"

$servers = get-ucsserver

foreach ($serv in $servers)
    {
        $serv |select-object @{N="Block";E={$serv.Ucs}},
        @{N="Physical Server";E={$serv.Dn}},
        @{N="Serial #";E={$serv.Serial}},
        @{N="Model";E={$serv.Model}},
        @{N="Mfg Date";E={$serv.MfgTime}},
        @{N="Sockets";E={$serv.NumofCpus}},
        @{N="Cores";E={$serv.NumOfCores}},
        @{N="Total RAM";E={$serv.TotalMemory}},
        @{N="Available RAM";E={$serv.AvailableMemory}},
        @{N="RAM Speed";E={$serv.MemorySpeed}},
        @{N="Operational State";E={$serv.OperState}},
        @{N="Service Profile";E={$serv.AssignedToDn}} |export-csv -Path $servlogfile -NoTypeInformation -Append
    }

#$chassisData=get-ucschassis |Select-Object Ucs, Dn, Serial, Model, MfgTime

$chassis = get-ucschassis

foreach ($chas in $chassis)
    {
        $chas |Select-Object @{N="Block";E={$chas.Ucs}},
        @{N="Chassis";E={$chas.Rn}},
        @{N="Serial #";E={$chas.Serial}},
        @{N="Model";E={$chas.Model}},
        @{N="Mfg Time";E={$chas.MfgTime}} |export-csv -Path $chassisLogFile -NoTypeInformation -Append
    }

$fabric = get-ucsnetworkelement

foreach ($fi in $fabric)
    {
        $fi |Select-Object @{N="Block";E={$fi.Ucs}},
        @{N="FI Switch";E={$fi.Dn}},
        @{N="Serial #";E={$fi.Serial}},
        @{N="Model";E={$fi.Model}},
        @{N="Total RAM";E={$fi.TotalMemory}} |export-csv -Path $fiLogFile -NoTypeInformation -Append
    }
#$chassisData |export-csv -Path $logfile -NoTypeInformation

#$serverData |export-csv -Path $logfile -NoTypeInformation -Append

Disconnect-Ucs

