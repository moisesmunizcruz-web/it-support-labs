# Script de verificacion de solo lectura para ejecutar dentro de la VM Server.
# Preparado despues de la configuracion manual; no ejecutado aun en Server.
# Ejecutar en Windows PowerShell como administrador.

$ErrorActionPreference = 'Stop'

Write-Output '=== Identidad ==='
whoami
hostname

Write-Output '=== Red de Server ==='
Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 |
    Select-Object IPAddress, PrefixLength, AddressState
Get-DnsClientServerAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 |
    Select-Object -ExpandProperty ServerAddresses

Write-Output '=== Dominio ==='
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, PDCEmulator

Write-Output '=== Servicios ==='
Get-Service NTDS, DNS | Select-Object Name, Status

Write-Output '=== Localizacion DNS del controlador ==='
Resolve-DnsName -Name '_ldap._tcp.dc._msdcs.itlab.test' -Type SRV -Server '10.77.30.10' |
    Select-Object NameTarget, Port

Write-Output '=== SYSVOL y NETLOGON ==='
Get-SmbShare -Name SYSVOL, NETLOGON | Select-Object Name, Path

Write-Output '=== Unidades organizativas ==='
Get-ADOrganizationalUnit -SearchBase 'OU=Soporte-Lab,DC=itlab,DC=test' -Filter * |
    Select-Object Name, DistinguishedName

Write-Output '=== Diagnostico de AD ==='
dcdiag /test:Advertising /test:SysVolCheck
