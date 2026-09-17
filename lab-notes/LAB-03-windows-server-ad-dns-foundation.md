# LAB-03 — Windows Server 2022, Active Directory y DNS

**Estado:** etapa 1 completada el 17 de septiembre de 2026. El servidor, el dominio, DNS y la estructura inicial de unidades organizativas están configurados y verificados. Las cuentas de prueba, las directivas de grupo y la validación desde un cliente corresponden a la siguiente etapa.

## Objetivo y alcance

Crear un laboratorio de Active Directory en Hyper-V para practicar tareas de soporte de TI: instalación de Windows Server, red interna, promoción a controlador de dominio, resolución DNS y organización de objetos. Esta bitácora registra comandos ejecutados manualmente y resultados observados. **Los bloques de comandos son una referencia histórica; no se deben ejecutar de nuevo sobre el entorno existente.**

## Entorno

| Componente | Configuración observada |
| --- | --- |
| Anfitrión | Windows con Hyper-V; equipo `PCMOISES` |
| VM | Nombre visible `Server` (antes `WS2022-DC01`); generación 2; 2 vCPU; 6 GiB de memoria inicial; VHDX dinámico de hasta 80 GiB |
| Sistema invitado | Windows Server 2022 Standard Evaluation con experiencia de escritorio; compilación 20348 |
| ISO | `SERVER_EVAL_x64FRE_es-es.iso`, obtenida del Centro de evaluación de Microsoft; 5,055,336,448 bytes |
| SHA-256 local de la ISO | `052C7D7785A99DB7C5FF710090050FBD424A2F17312F0C6463E959E4E19CEE98` |
| Red | Conmutador interno de Hyper-V `Lab-AD`; anfitrión `10.77.30.1/24`; VM Server `10.77.30.10/24`, sin puerta de enlace |
| Identidad | Nombre de Windows `SERVER-LAB`; dominio `itlab.test`; NetBIOS `ITLAB` |
| DNS de Server | `10.77.30.10` |

El hash identifica el archivo descargado localmente; no se comparó con una suma de comprobación publicada por Microsoft. La ruta del VHDX conserva el nombre inicial de la VM: `C:\IT-Labs\VMs\WS2022-DC01\WS2022-DC01.vhdx`. La segunda VM del anfitrión se llama `Ubuntu` y estaba guardada durante esta etapa para liberar memoria.

```text
Anfitrión PCMOISES ── vEthernet (Lab-AD): 10.77.30.1/24
          │
          └── Conmutador interno Lab-AD
                    │
                    └── VM Server / SERVER-LAB: 10.77.30.10/24
                              ├── AD DS: itlab.test
                              └── DNS: 10.77.30.10
```

## 1. Preparación e instalación

En la **consola administrativa del anfitrión**, se creó inicialmente la VM con `New-VM`, se montó la ISO en la unidad de DVD virtual, se puso el DVD primero en el orden de arranque y se asignaron dos procesadores. En el instalador se eligió **Windows Server 2022 Standard Evaluation (experiencia de escritorio)** y la instalación personalizada sobre los 80 GB sin asignar. Se estableció la contraseña de `Administrador` mediante el asistente; no se incluye en esta bitácora.

El primer arranque falló por memoria insuficiente (`0x800705AA`): el anfitrión tenía 5.25 GiB libres y Ubuntu utilizaba 8 GiB. Se guardó Ubuntu con `Save-VM`; la memoria libre subió a 13.54 GiB y Server pudo arrancar. Los nombres visibles de ambas VM se cambiaron posteriormente a `Server` y `Ubuntu`. El cambio de nombre visible de la VM no cambia el nombre de Windows dentro de ella.

Server utilizó inicialmente el `Default Switch` para instalar actualizaciones. En esa red obtuvo `172.21.56.181` por DHCP y pasó una prueba TCP al puerto 443 de `www.microsoft.com`. Más adelante se trasladó a la red interna `Lab-AD`.

Dentro de la **consola administrativa de Server**, el nombre de Windows se cambió y se comprobó tras reiniciar:

```powershell
Rename-Computer -NewName 'SERVER-LAB'
# Tras reiniciar:
hostname
# SERVER-LAB
```

Se configuró la zona `Central Standard Time (Mexico)`. Antes de actualizar Windows, el offset mostrado para septiembre era `-05:00` con `UBR=587`; después de Windows Update, `UBR=5622` y `Get-Date -Format o` mostró `-06:00`. El usuario confirmó también la hora correcta en la barra de tareas.

## 2. Red interna del laboratorio

En el **anfitrión** se creó el conmutador interno `Lab-AD`, se asignó `10.77.30.1/24` a `vEthernet (Lab-AD)` y se conectó la NIC de la VM `Server` a ese conmutador. La dirección del anfitrión se verificó en estado `Preferred` en ActiveStore. PersistentStore mostró la misma dirección con estado `Invalid`; su comportamiento después de reiniciar el anfitrión aún no se ha probado.

```powershell
# Comandos ejecutados en el anfitrión
New-VMSwitch -Name 'Lab-AD' -SwitchType Internal
New-NetIPAddress -InterfaceAlias 'vEthernet (Lab-AD)' -IPAddress '10.77.30.1' -PrefixLength 24
Connect-VMNetworkAdapter -VMName 'Server' -SwitchName 'Lab-AD'
```

En la **VM Server**, se configuró la interfaz `Ethernet` con IP fija y DNS local. La comprobación posterior mostró `10.77.30.10/24` en estado `Preferred`, DHCP deshabilitado, DNS `10.77.30.10` y ninguna puerta de enlace.

```powershell
# Comandos ejecutados dentro de Server
New-NetIPAddress -InterfaceAlias 'Ethernet' -IPAddress '10.77.30.10' -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '10.77.30.10'
```

`Test-NetConnection 10.77.30.1` confirmó `PingSucceeded=True` desde `10.77.30.10`; `Get-NetNeighbor` mostró al anfitrión en estado `Reachable`. Esta red es interna y Server no tiene una ruta de salida configurada.

**Corrección realizada:** la primera vez, los comandos destinados a `Ethernet` de Server se pegaron por error en la consola del anfitrión. Se añadió `10.77.30.10` a `Ethernet` del anfitrión y se cambió su DNS. Se eliminó esa IP de los almacenes activo y persistente, se restableció DNS automático y se comprobó que el anfitrión conservaba solo su dirección APIPA previa en `Ethernet` y `10.77.30.1` en `vEthernet (Lab-AD)`. Después se ejecutó la configuración correcta dentro de Server. La etiqueta de consola es la referencia esencial para no confundir sistemas: `PS C:\IT-Labs>` en el anfitrión y `PS C:\Users\Administrador>` en Server.

## 3. AD DS, DNS y promoción

En la **VM Server** se instalaron los roles y herramientas de administración. La salida mostró `Success=True`, `RestartNeeded=No` y ambos roles `Installed`.

```powershell
Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools
Get-WindowsFeature -Name AD-Domain-Services,DNS | Select-Object Name,InstallState
```

Después se creó el bosque `itlab.test` con DNS. La contraseña de restauración de servicios de directorio se introdujo en el prompt seguro y no se guardó en este repositorio.

```powershell
Install-ADDSForest -DomainName 'itlab.test' -DomainNetbiosName 'ITLAB' -InstallDNS -Force
```

Server se reinició. La pantalla de acceso mostró `ITLAB\Administrador`; `whoami` devolvió `itlab\administrador`.

## 4. Validación observada

| Prueba | Resultado |
| --- | --- |
| Dominio | `Get-ADDomain`: `DNSRoot=itlab.test`, `NetBIOSName=ITLAB`, `PDCEmulator=SERVER-LAB.itlab.test` |
| Servicios | `NTDS` y `DNS` en estado `Running` |
| Localización del controlador | Consulta SRV `_ldap._tcp.dc._msdcs.itlab.test` a `10.77.30.10`: `server-lab.itlab.test`, puerto `389` |
| Diagnóstico AD | `dcdiag /test:Advertising /test:SysVolCheck`: pasaron Connectivity, Advertising y SysVolCheck |
| Recursos compartidos | `SYSVOL` y `NETLOGON` presentes bajo `C:\Windows\SYSVOL\sysvol\itlab.test` |

Se creó la siguiente estructura inicial de unidades organizativas:

```text
DC=itlab,DC=test
└── OU=Soporte-Lab
    ├── OU=Usuarios
    ├── OU=Grupos
    └── OU=Equipos
```

`Get-ADOrganizationalUnit` devolvió las cuatro unidades con los DN esperados. El script de [verificación](../scripts/LAB-03-verify-foundation.ps1) reúne pruebas de solo lectura para futuras revisiones; se preparó después de la configuración manual y todavía no se ha ejecutado en Server.

## Incidencias y límites de la evidencia

- Después del reinicio solicitado para aplicar el nombre `SERVER-LAB`, Windows mostró un aviso de apagado inesperado. El registro System contenía un evento 1074 de reinicio solicitado, seguido de 41 y 6008 de cierre no limpio. `BugcheckCode=0`, `PowerButtonTimestamp=0` y no se observó un evento 1001 en la búsqueda realizada. **No se determinó la causa.** Server volvió a iniciar y las verificaciones posteriores pasaron.
- Durante Windows Update, VMConnect dejó de conectar aunque Hyper-V mostraba Server en ejecución. Desactivar temporalmente el modo de sesión mejorada en el anfitrión permitió usar la consola básica. Tras la actualización se reactivó ese modo; al volver a abrir VMConnect funcionó otra vez el portapapeles compartido.
- Las capturas documentan resultados puntuales. No prueban persistencia de la red después de reiniciar el anfitrión ni sustituyen una validación desde un cliente unido al dominio.

## Evidencias seleccionadas

1. [Conmutador e IP del anfitrión](../evidence/LAB-03-01-host-network.png) — `Lab-AD`, interfaz y `10.77.30.1`.
2. [IP y DNS de Server](../evidence/LAB-03-02-server-network.png) — `10.77.30.10/24`, DHCP deshabilitado.
3. [Conectividad Server → anfitrión](../evidence/LAB-03-03-connectivity.png) — ping y vecino alcanzable.
4. [Roles instalados](../evidence/LAB-03-04-roles.png) — AD DS y DNS.
5. [Dominio y localización DNS](../evidence/LAB-03-05-domain-dns.png) — servicios y registro SRV.
6. [Diagnóstico y unidades organizativas](../evidence/LAB-03-06-dcdiag-ous.png) — pruebas AD, SYSVOL, NETLOGON y cuatro OU.

## Siguiente etapa

- Crear usuarios y grupos de prueba en sus unidades organizativas y verificar membresías.
- Configurar y vincular una GPO con un efecto comprobable.
- Preparar un cliente Windows, unirlo a `itlab.test`, iniciar sesión con una cuenta de prueba y verificar DNS, acceso y aplicación de la GPO.
- Cerrar y revisar las transcripciones originales antes de publicar extractos; conservar fuera de GitHub contraseñas, secretos y registros sin revisar.
- Añadir el caso de Jira y actualizar esta misma bitácora con los resultados restantes.
