# Bitácora consolidada del laboratorio de soporte TI

**Periodo registrado:** 16–17 de septiembre de 2026<br>
**Entorno:** anfitrión Windows 11 Pro con Hyper-V; VM `Ubuntu` (antes `Ubuntu-Support-Lab`) y VM `Server` (antes `WS2022-DC01`).<br>
**Naturaleza:** práctica personal, autodirigida y simulada. No representa soporte a una empresa, usuarios o sistemas de producción.

## Cómo leer esta bitácora

Este documento reúne los ejercicios en orden de ejecución. Cada comando aparece junto a su función y, cuando consta en las evidencias, el resultado relevante. Se omiten el diálogo de la sesión, los intentos fallidos y las correcciones operativas. Las pruebas de acceso denegado que fueron **intencionales** se conservan porque verifican los permisos.

Los comandos son una **transcripción depurada**, no un script para ejecutar de principio a fin: varios crean recursos que ya existen y otros reinician equipos. La IP `172.21.53.73` fue la dirección observada de Ubuntu en el `Default Switch`; puede cambiar. Las contraseñas, tokens y entradas privadas no se reproducen. La VM Ubuntu ya estaba creada e instalada cuando comenzó esta serie de prácticas; por eso no se atribuyen aquí comandos de creación o instalación de esa VM.

Las etiquetas **ANFITRIÓN**, **UBUNTU** y **SERVER** señalan dónde se ejecutó cada comando. En las etapas iniciales la VM Ubuntu aún se llamaba `Ubuntu-Support-Lab`; el cambio de nombre se registra en LAB-03.

---

## SETUP-01 · GitHub, Git y acceso SSH a Ubuntu

**Objetivo.** Preparar un repositorio público para documentar las prácticas y administrar Ubuntu desde Windows Terminal. La cuenta de GitHub y la VM Ubuntu ya existían al comenzar.

### UBUNTU · Preparación de Git y del repositorio

1. `git --version` — Comprobó la disponibilidad de Git antes de instalarlo.
2. `sudo apt update` — Actualizó el índice de paquetes de Ubuntu.
3. `sudo apt install git` — Instaló Git desde los repositorios de Ubuntu.
4. `git --version` — Verificó la instalación; se observó `git version 2.53.0`.
5. `git clone https://github.com/moisesmunizcruz-web/it-support-labs.git` — Copió a Ubuntu el repositorio público creado previamente en GitHub.
6. `cd it-support-labs` — Entró en la copia local del repositorio.
7. `mkdir lab-notes support-cases knowledge-base evidence` — Creó las carpetas para notas técnicas, casos simulados, guías y pruebas revisadas.
8. `git config --global user.name "moisesmunizcruz-web"` — Definió la identidad pública para los commits de la VM.
9. `git config --global user.email "245904379+moisesmunizcruz-web@users.noreply.github.com"` — Configuró la dirección `noreply` de GitHub para no publicar el correo personal en commits futuros.
10. `git config user.email` — Comprobó qué dirección usaría el repositorio.

El repositorio se inició con un `README.md` bilingüe. Se añadieron archivos `.gitkeep` a carpetas todavía vacías para que Git pudiera conservar su estructura. El comando exacto utilizado para crear cada `.gitkeep` no consta en las fuentes revisadas; por eso no se presenta uno supuesto.

### UBUNTU Y ANFITRIÓN · Acceso remoto

1. **UBUNTU:** `sudo apt install openssh-server` — Instaló el servidor OpenSSH.
2. **UBUNTU:** `systemctl is-active ssh.socket` — Confirmó que el punto de entrada SSH estaba activo; respondió `active`.
3. **UBUNTU:** `ip -4 -brief address` — Mostró la IPv4 de `eth0`; se observó `172.21.53.73`.
4. **ANFITRIÓN:** `ssh mmuniz@172.21.53.73` — Abrió desde Windows Terminal una sesión en Ubuntu. El prompt `mmuniz@ubuntu:~$` distinguía la sesión remota de PowerShell.

### UBUNTU · Documentación y publicación inicial

1. `cd ~/it-support-labs` — Entró en la raíz del repositorio.
2. `nano README.md` — Editó la presentación bilingüe del portafolio y la aclaración de que la práctica es simulada.
3. `git diff -- README.md` — Revisó el cambio al README antes de registrarlo.
4. `nano lab-notes/SETUP-01-repository-and-ssh.md` — Creó la nota sobre la preparación de Git, el repositorio y SSH.
5. `cat lab-notes/SETUP-01-repository-and-ssh.md` — Comprobó el contenido guardado.
6. `git status --short` — Revisó qué archivos habían cambiado.
7. `git add lab-notes/SETUP-01-repository-and-ssh.md` — Preparó la revisión posterior de la nota.
8. `git commit -m "docs: expand setup diagnosis and validation"` — Guardó una versión ampliada de la nota en el historial local.
9. `git log -1 --oneline` — Comprobó el commit más reciente.
10. `git status --short` — Verificó el estado del árbol de trabajo.
11. `git push origin main` — Publicó en GitHub las revisiones preparadas del README y de `SETUP-01`.

El README y `SETUP-01` se publicaron en el repositorio. Los primeros comandos exactos de `git add` y el mensaje del primer commit no están conservados en los registros disponibles; se omiten en lugar de reconstruirlos.

**Resultado.** Git quedó instalado, el repositorio se pudo clonar y actualizar, y Windows Terminal pudo abrir una sesión SSH de Ubuntu.

---

## LAB-00 · Línea base de Ubuntu y su red

**Objetivo.** Registrar el estado de la VM ya instalada, aplicar actualizaciones ordinarias y comprobar acceso remoto, conectividad IP y DNS. [Nota publicada de LAB-00](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-00-ubuntu-support-lab-build-and-baseline.md).

### ANFITRIÓN · Inventario de Hyper-V

1. `Get-VM -Name "Ubuntu-Support-Lab" | Select-Object Name, State, Generation, ProcessorCount, MemoryAssigned` — Consultó estado, generación, CPU y memoria. Se observaron generación 2, cuatro procesadores y 8 GiB asignados.
2. `Get-VMNetworkAdapter -VMName "Ubuntu-Support-Lab" | Select-Object VMName, SwitchName, Status` — Confirmó que el adaptador estaba conectado a `Default Switch` y en estado `Ok`.

### UBUNTU · Sistema y almacenamiento

1. `hostnamectl` — Identificó Ubuntu 26.04.1 LTS, kernel y arquitectura del sistema invitado.
2. `df -h /` — Midió el espacio de la partición raíz: 58 GB totales, alrededor de 11 GB usados y 45 GB disponibles.
3. `script -q ~/LAB-00-session.log` — Inició la grabación de la salida de terminal en el directorio personal, fuera del repositorio.
4. `sudo apt update` — Actualizó el índice de paquetes; se detectaron 17 actualizables en esta comprobación.
5. `apt list --upgradable` — Mostró los paquetes con actualizaciones disponibles.
6. `sudo apt upgrade` — Instaló nueve actualizaciones. Ocho paquetes quedaron pendientes por distribución gradual de Ubuntu.
7. `apt list --upgradable` — Comprobó qué paquetes seguían pendientes.
8. `cat /var/run/reboot-required` — Consultó el aviso de reinicio requerido.
9. `exit` — Cerró la grabación de `script` sin cerrar la sesión SSH principal.
10. `sudo reboot` — Reinició Ubuntu después de actualizarlo.

### ANFITRIÓN Y UBUNTU · Validación posterior

1. **ANFITRIÓN:** `ssh mmuniz@172.21.53.73` — Volvió a conectar por SSH tras el reinicio; en esa ocasión Ubuntu conservó la misma dirección.
2. **UBUNTU:** `uptime -s` — Confirmó la hora del nuevo arranque.
3. **UBUNTU:** `systemctl is-active ssh.socket` — Confirmó que el acceso SSH seguía activo.
4. **UBUNTU:** `script -a -q ~/LAB-00-session.log` — Añadió las pruebas de red al mismo registro de sesión.
5. **UBUNTU:** `ip -4 -brief address` — Confirmó `eth0` activa con `172.21.53.73/20`.
6. **UBUNTU:** `ip route` — Mostró una ruta predeterminada a través de `172.21.48.1`.
7. **UBUNTU:** `ping -c 3 1.1.1.1` — Probó salida IP; recibió tres respuestas de tres.
8. **UBUNTU:** `resolvectl query ubuntu.com` — Confirmó la resolución de nombres DNS.
9. **UBUNTU:** `exit` — Cerró la grabación adicional.

### UBUNTU · Nota y evidencia

1. `cd ~/it-support-labs` — Entró en el repositorio.
2. `nano lab-notes/LAB-00-ubuntu-support-lab-build-and-baseline.md` — Redactó la línea base, las comprobaciones y los resultados.
3. `git status --short` — Revisó la nota y las imágenes incorporadas.
4. `git add lab-notes/LAB-00-ubuntu-support-lab-build-and-baseline.md evidence/LAB-00-windows-hyper-v.png evidence/LAB-00-ubuntu-network.png` — Preparó la nota y dos capturas revisadas para el commit de evidencia.
5. `git commit -m "docs: add LAB-00 evidence from Windows and Ubuntu"` — Registró la nota actualizada y las capturas.
6. `git push origin main` — Publicó el commit en GitHub.

Las dos imágenes se transfirieron desde el anfitrión a Ubuntu mediante `scp`. El archivo original `~/LAB-00-session.log` se mantuvo fuera de GitHub.

**Resultado.** La VM siguió accesible por SSH tras reiniciar; quedaron validadas la interfaz, la ruta, la conectividad IP y DNS.

---

## LAB-01 · Cuentas locales, grupos y carpeta compartida en Ubuntu

**Caso simulado:** solicitud IT-1 en Jira Service Management.<br>
**Objetivo.** Crear tres usuarios de práctica, asignar grupos y verificar el acceso colaborativo a `/srv/soporte_l1`. Los comandos de esta sección proceden del registro revisado de la sesión. [Nota publicada de LAB-01](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-01-local-users-groups-and-shared-access.md).

### UBUNTU · Registro, grupos y cuentas

1. `script -q ~/LAB-01-session.log` — Inició una grabación de salida de terminal fuera del repositorio.
2. `sudo addgroup soporte_l1` — Creó el grupo del equipo de soporte.
3. `sudo addgroup supervisores_ti` — Creó el grupo adicional de supervisión.
4. `sudo adduser agente01` — Creó el primer usuario ficticio y su carpeta personal; la contraseña se definió mediante el diálogo interactivo.
5. `sudo adduser agente02` — Creó el segundo usuario ficticio.
6. `sudo adduser supervisor01` — Creó el usuario ficticio de supervisión.
7. `sudo adduser agente01 soporte_l1` — Añadió `agente01` al equipo de soporte.
8. `sudo adduser agente02 soporte_l1` — Añadió `agente02` al equipo de soporte.
9. `sudo adduser supervisor01 soporte_l1` — Dio al supervisor acceso al grupo de soporte.
10. `sudo adduser supervisor01 supervisores_ti` — Lo incorporó además al grupo de supervisores.
11. `id agente01` — Verificó la pertenencia del primer agente.
12. `id agente02` — Verificó la pertenencia del segundo agente.
13. `id supervisor01` — Verificó las dos membresías adicionales del supervisor.

### UBUNTU · Carpeta de trabajo y control de acceso

1. `sudo mkdir /srv/soporte_l1` — Creó la carpeta de trabajo del equipo.
2. `sudo chown root:soporte_l1 /srv/soporte_l1` — Asignó `root` como propietario y `soporte_l1` como grupo.
3. `sudo chmod 2770 /srv/soporte_l1` — Dio acceso al propietario y al grupo, excluyó a otros y activó setgid para heredar el grupo.
4. `ls -ld /srv/soporte_l1` — Confirmó los permisos `drwxrws---`.
5. `sudo -u agente01 touch /srv/soporte_l1/prueba-agente01.txt` — Comprobó que el primer agente podía crear un archivo.
6. `sudo -u agente02 touch /srv/soporte_l1/prueba-agente02.txt` — Comprobó el mismo acceso para el segundo agente.
7. `sudo -u supervisor01 touch /srv/soporte_l1/prueba-supervisor01.txt` — Comprobó el acceso del supervisor.
8. `touch /srv/soporte_l1/prueba-mmuniz.txt` — Prueba deliberada desde una cuenta fuera de `soporte_l1`; el acceso fue denegado como se esperaba.
9. `ls -l /srv/soporte_l1` — Segunda prueba deliberada de acceso desde esa cuenta; el listado fue denegado.
10. `sudo ls -l /srv/soporte_l1` — Mostró los tres archivos y el grupo heredado `soporte_l1`.

### UBUNTU · Autenticación de las cuentas

1. `su - agente01` → `whoami` → `exit` — Verificó inicio de sesión y nombre efectivo de `agente01`.
2. `su - agente02` → `whoami` → `exit` — Repitió la prueba con `agente02`.
3. `su - supervisor01` → `whoami` → `exit` — Repitió la prueba con `supervisor01`.

Las contraseñas se ingresaron en prompts interactivos y no forman parte de la transcripción publicada.

### UBUNTU · Permisos de edición compartida

1. `command -v setfacl` — Confirmó que la herramienta de ACL estaba instalada.
2. `sudo setfacl -d -m u::rwx,g::rwx,o::--- /srv/soporte_l1` — Definió permisos predeterminados para nuevos objetos: escritura de grupo y ningún acceso para otros.
3. `sudo getfacl -d /srv/soporte_l1` — Comprobó la ACL predeterminada.
4. `sudo -u agente01 touch /srv/soporte_l1/compartido.txt` — Creó un archivo nuevo bajo la ACL.
5. `sudo ls -l /srv/soporte_l1/compartido.txt` — Confirmó `-rw-rw----` y grupo `soporte_l1`.
6. `printf '%s\n' 'Revisión realizada por agente02' | sudo -u agente02 tee -a /srv/soporte_l1/compartido.txt` — Añadió contenido al archivo usando la cuenta del segundo agente.
7. `sudo -u supervisor01 cat /srv/soporte_l1/compartido.txt` — Confirmó que el supervisor podía leer el contenido.
8. `exit` — Terminó la grabación de `script`.

La ACL predeterminada se aplica a los archivos creados **después** de configurarla; los archivos anteriores conservaron sus permisos originales. El caso IT-1 quedó marcado como **Resuelta / Completado** en Jira.

### Publicación del caso

1. **ANFITRIÓN:** `scp mmuniz@172.21.53.73:/home/mmuniz/LAB-01-session.log .\LAB-01-session.raw.log` — Trajo una copia del registro original a Windows para preparar una versión revisada.
2. **ANFITRIÓN:** `scp .\lab-notes\LAB-01-local-users-groups-and-shared-access.md "mmuniz@172.21.53.73:/home/mmuniz/it-support-labs/lab-notes/"` — Copió la nota depurada al repositorio de Ubuntu.
3. **UBUNTU:** `git add lab-notes/LAB-01-local-users-groups-and-shared-access.md evidence/LAB-01-*.png evidence/LAB-01-session-reviewed.log` — Preparó la nota, capturas y transcripción revisada; el registro original quedó fuera.
4. **UBUNTU:** `git diff --cached --stat` — Comprobó el conjunto de archivos preparados.
5. **UBUNTU:** `git diff --cached --check` — Revisó el formato de los cambios.
6. **UBUNTU:** `git commit -m "docs: document LAB-01 accounts, access tests and Jira resolution"` — Registró LAB-01 en Git.
7. **UBUNTU:** `git push origin main` — Publicó la nota y evidencia.
8. **UBUNTU:** `git status --short` — Confirmó que no quedaron cambios pendientes después de la publicación.

**Resultado.** Se verificaron tres cuentas, dos grupos, acceso por membresía, denegación a una cuenta externa y edición compartida de un archivo nuevo.

---

## LAB-02 · Servicio web Nginx en Ubuntu

**Caso simulado:** IT-2 en Jira Service Management.<br>
**Objetivo.** Instalar Nginx, servir su página predeterminada y comprobar el acceso HTTP desde Ubuntu y Windows. [Nota publicada de LAB-02](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-02-web-service-incident.md).

### UBUNTU · Instalación y pruebas locales

1. `script -a ~/LAB-02-session.log` — Continuó el registro de la sesión en un archivo fuera del repositorio.
2. `sudo apt update` — Actualizó el índice de paquetes antes de instalar el servicio.
3. `sudo apt install nginx` — Instaló Nginx y sus dependencias.
4. `sudo systemctl status nginx --no-pager` — Confirmó el servicio `active (running)` y `enabled`.
5. `hostname -I` — Consultó la IPv4 de la VM utilizada para las pruebas desde Windows: `172.21.53.73`.
6. `sudo apt install curl` — Instaló la herramienta de pruebas HTTP.
7. `curl -I http://127.0.0.1/` — Solicitó solo cabeceras; obtuvo `HTTP/1.1 200 OK`.
8. `curl -s http://127.0.0.1/ | head -n 8` — Comprobó que el contenido servido incluía el título `Welcome to nginx!`.
9. `sudo nginx -t` — Validó la sintaxis de la configuración de Nginx.
10. `systemctl is-enabled nginx` — Confirmó que el servicio quedó habilitado para iniciar con el sistema.
11. `exit` — Cerró el registro de `script`.

### ANFITRIÓN · Acceso remoto al servicio

1. `Test-NetConnection 172.21.53.73 -Port 80` — Verificó que el puerto HTTP de Ubuntu era accesible desde Windows; `TcpTestSucceeded=True`.
2. `Invoke-WebRequest -Uri "http://172.21.53.73/" -Method Head | Select-Object StatusCode, StatusDescription` — Confirmó respuesta HTTP `200` desde Windows.

También se abrió la página de bienvenida desde el navegador del anfitrión. La comprobación fue por HTTP, sin TLS. El caso IT-2 quedó **Resuelto / Completado** en Jira.

### Publicación del caso

1. **ANFITRIÓN:** `scp mmuniz@172.21.53.73:/home/mmuniz/LAB-02-session.log .\LAB-02-session.raw.log` — Copió el registro original a un área local de revisión; el original no se publicó.
2. **ANFITRIÓN:** `scp ..\..\outputs\LAB-02-github-package.tar.gz mmuniz@172.21.53.73:/home/mmuniz/` — Envió a Ubuntu el paquete depurado.
3. **UBUNTU:** `tar -tzf ~/LAB-02-github-package.tar.gz` — Revisó su contenido antes de extraerlo.
4. **UBUNTU:** `tar -xzf ~/LAB-02-github-package.tar.gz -C ~/it-support-labs` — Colocó nota y evidencias dentro del repositorio.
5. **UBUNTU:** `git add lab-notes/LAB-02-web-service-incident.md evidence/LAB-02-*.png evidence/LAB-02-session-reviewed.log` — Preparó solo los archivos revisados de LAB-02.
6. **UBUNTU:** `git diff --cached --check` — Revisó el formato del contenido preparado.
7. **UBUNTU:** `git diff --cached --stat` — Confirmó diez archivos en el conjunto de publicación.
8. **UBUNTU:** `git commit -m "docs: document LAB-02 nginx service validation"` — Registró la nota y evidencias depuradas.
9. **UBUNTU:** `git push origin main` — Publicó el caso en GitHub.
10. **UBUNTU:** `git status --short` — Confirmó el estado de la copia de trabajo.

**Resultado.** La página predeterminada respondió localmente y desde Windows por el puerto 80, y la configuración del servicio pasó la validación de sintaxis.

---

## LAB-03 · Windows Server, Active Directory y DNS (etapa 1)

**Objetivo.** Crear una VM Windows Server, establecer una red interna, promoverla al primer controlador de `itlab.test` y verificar AD DS, DNS, SYSVOL y las unidades organizativas iniciales. [Nota publicada de LAB-03](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-03-windows-server-ad-dns-foundation.md).

### ANFITRIÓN · Preparación de archivos y VM

1. `New-Item -ItemType Directory -Path 'C:\IT-Labs' -Force` — Creó una ruta corta de trabajo para el laboratorio.
2. `Set-Location 'C:\IT-Labs'` — Estableció esa carpeta como directorio actual.
3. `New-Item -ItemType Directory -Path '.\ISO','.\VMs','.\evidence' -Force` — Organizó imagen de instalación, discos de VM y evidencias locales.
4. `Start-Transcript -Path '.\LAB-03-host-setup.log' -Append` — Registró la preparación del anfitrión.
5. `Get-VMSwitch | Select-Object Name, SwitchType` — Revisó los conmutadores virtuales existentes.
6. `Move-Item -LiteralPath "$env:USERPROFILE\Downloads\SERVER_EVAL_x64FRE_es-es.iso" -Destination '.\ISO\SERVER_EVAL_x64FRE_es-es.iso'` — Colocó la ISO de evaluación de Windows Server 2022 en la carpeta del laboratorio.
7. `Get-Item -LiteralPath '.\ISO\SERVER_EVAL_x64FRE_es-es.iso' | Select-Object Name, Length` — Comprobó el archivo y su tamaño.
8. `Get-FileHash -Algorithm SHA256 -LiteralPath '.\ISO\SERVER_EVAL_x64FRE_es-es.iso'` — Calculó el SHA-256 local de la ISO.
9. `New-Item -ItemType Directory -Path '.\VMs\WS2022-DC01' -Force` — Preparó la ruta de la nueva VM.
10. `New-VM -Name 'WS2022-DC01' -Generation 2 -MemoryStartupBytes 6GB -NewVHDPath 'C:\IT-Labs\VMs\WS2022-DC01\WS2022-DC01.vhdx' -NewVHDSizeBytes 80GB -Path 'C:\IT-Labs\VMs\WS2022-DC01' -SwitchName 'Default Switch'` — Creó la VM generación 2, con 6 GiB de memoria inicial y disco virtual de hasta 80 GiB.
11. `Get-VM -Name 'WS2022-DC01' | Select-Object Name, State, Generation, MemoryStartup, Path` — Comprobó la VM recién creada.
12. `Get-VMHardDiskDrive -VMName 'WS2022-DC01' | Select-Object Path` — Verificó el disco virtual asociado.
13. `Add-VMDvdDrive -VMName 'WS2022-DC01' -Path 'C:\IT-Labs\ISO\SERVER_EVAL_x64FRE_es-es.iso'` — Montó la ISO en el DVD virtual.
14. `Get-VMDvdDrive -VMName 'WS2022-DC01' | Select-Object ControllerNumber, ControllerLocation, Path` — Confirmó la unidad y su imagen.
15. `Set-VMFirmware -VMName 'WS2022-DC01' -FirstBootDevice (Get-VMDvdDrive -VMName 'WS2022-DC01')` — Priorizó el DVD para instalar Windows Server.
16. `(Get-VMFirmware -VMName 'WS2022-DC01').BootOrder` — Verificó el orden de arranque configurado.
17. `Set-VMProcessor -VMName 'WS2022-DC01' -Count 2` — Asignó dos procesadores virtuales.
18. `Get-VMProcessor -VMName 'WS2022-DC01' | Select-Object Count` — Comprobó el número de vCPU.
19. `Save-VM -Name 'Ubuntu-Support-Lab'` — Guardó temporalmente Ubuntu para liberar memoria del anfitrión durante la instalación de Server.
20. `vmconnect.exe localhost WS2022-DC01` — Abrió la consola gráfica de la VM para instalar Windows Server.

El SHA-256 local de la ISO fue `052C7D7785A99DB7C5FF710090050FBD424A2F17312F0C6463E959E4E19CEE98`; no se comparó con un hash publicado por Microsoft. En el asistente gráfico se eligió **Windows Server 2022 Standard Evaluation (experiencia de escritorio)** y la instalación personalizada en el disco virtual de 80 GB. La contraseña de Administrador se introdujo en la interfaz y no se documenta.

### SERVER · Sistema operativo, hora y nombre

1. `New-Item -ItemType Directory -Path 'C:\Lab-Evidence' -Force` — Creó una carpeta para el registro local de Server.
2. `Start-Transcript -Path 'C:\Lab-Evidence\LAB-03-server-setup.log' -Append` — Inició el registro de PowerShell dentro de la VM.
3. `Get-ComputerInfo -Property CsName,WindowsProductName,OsBuildNumber | Format-List` — Comprobó identidad y versión: Windows Server 2022 Standard Evaluation, compilación 20348.
4. `Get-TimeZone` — Consultó la zona horaria inicial.
5. `Set-TimeZone -Id 'Central Standard Time (Mexico)'` — Estableció la zona del centro de México.
6. `Get-Date -Format o` — Comprobó fecha, hora y offset UTC.
7. `Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object CurrentBuild,UBR` — Registró compilación y revisión de Windows antes y después de actualizar; tras Windows Update se observó `20348` / `5622`.
8. `Test-NetConnection www.microsoft.com -Port 443` — Confirmó conectividad HTTPS mientras Server estaba en `Default Switch`.
9. `Rename-Computer -NewName 'SERVER-LAB'` — Cambió el nombre del sistema invitado.
10. `Stop-Transcript` — Cerró el registro antes de reiniciar.
11. `Restart-Computer` — Solicitó el reinicio para aplicar el nombre.
12. `hostname` — Confirmó `SERVER-LAB` después de iniciar sesión de nuevo.
13. `Start-Transcript -Path 'C:\Lab-Evidence\LAB-03-server-setup.log' -Append` — Reanudó el mismo registro tras el reinicio.

Windows Update se realizó desde la interfaz gráfica antes de establecer la red interna. Después de actualizar, el reloj mostró el offset `-06:00` esperado para la zona configurada.

### ANFITRIÓN · Red y nombres visibles de las VM

1. `Start-Transcript -Path 'C:\IT-Labs\evidence\LAB-03-host-network.log' -Append` — Inició el registro de la configuración de red del anfitrión.
2. `New-VMSwitch -Name 'Lab-AD' -SwitchType Internal` — Creó un conmutador interno para el dominio de laboratorio.
3. `New-NetIPAddress -InterfaceAlias 'vEthernet (Lab-AD)' -IPAddress '10.77.30.1' -PrefixLength 24` — Asignó al anfitrión la dirección `10.77.30.1/24` en esa red.
4. `Get-VMSwitch -Name 'Lab-AD' | Select-Object Name,SwitchType` — Verificó el conmutador.
5. `Get-NetIPAddress -InterfaceAlias 'vEthernet (Lab-AD)' -AddressFamily IPv4 -PolicyStore ActiveStore | Select-Object IPAddress,PrefixLength,AddressState` — Confirmó la dirección `Preferred` en el estado activo.
6. `Rename-VM -Name 'WS2022-DC01' -NewName 'Server'` — Cambió el nombre visible de la VM Windows Server en Hyper-V.
7. `Rename-VM -Name 'Ubuntu-Support-Lab' -NewName 'Ubuntu'` — Cambió el nombre visible de la VM Ubuntu.
8. `Get-VM | Select-Object Name,State` — Comprobó ambos nombres y estados.
9. `Connect-VMNetworkAdapter -VMName 'Server' -SwitchName 'Lab-AD'` — Conectó Server al conmutador interno.
10. `Get-VMNetworkAdapter -VMName 'Server' | Select-Object Name,SwitchName` — Confirmó la asociación a `Lab-AD`.

### SERVER · Dirección fija y conectividad interna

1. `Get-NetAdapter | Select-Object Name,Status,InterfaceDescription` — Identificó la interfaz invitada `Ethernet` y su adaptador de Hyper-V.
2. `Get-NetIPConfiguration -InterfaceAlias 'Ethernet' | Format-List IPv4Address,IPv4DefaultGateway,DNSServer` — Inspeccionó la interfaz del invitado.
3. `New-NetIPAddress -InterfaceAlias 'Ethernet' -IPAddress '10.77.30.10' -PrefixLength 24` — Asignó `10.77.30.10/24` a Server; DHCP quedó deshabilitado.
4. `Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '10.77.30.10'` — Configuró al propio Server como DNS del dominio.
5. `Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 | Select-Object IPAddress,PrefixLength,AddressState` — Confirmó la IP en estado `Preferred`.
6. `Get-DnsClientServerAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses` — Confirmó `10.77.30.10` como DNS numérico.
7. `Test-NetConnection -ComputerName '10.77.30.1' -InformationLevel Detailed | Format-List ComputerName,RemoteAddress,InterfaceAlias,SourceAddress,PingSucceeded` — Verificó ping al anfitrión desde `10.77.30.10`.
8. `Get-NetNeighbor -InterfaceAlias 'Ethernet' -IPAddress '10.77.30.1' | Format-List IPAddress,LinkLayerAddress,State` — Confirmó al anfitrión como vecino alcanzable.

Esta red no tiene puerta de enlace configurada en Server. Su finalidad es la comunicación interna del laboratorio.

### SERVER · Roles y promoción a controlador de dominio

1. `Get-WindowsFeature -Name AD-Domain-Services,DNS | Select-Object Name,InstallState` — Revisó el estado de los roles.
2. `Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools` — Instaló AD DS, DNS y herramientas de administración; ambos roles quedaron `Installed`.
3. `Get-WindowsFeature -Name AD-Domain-Services,DNS | Select-Object Name,InstallState` — Confirmó la instalación.
4. `Install-ADDSForest -DomainName 'itlab.test' -DomainNetbiosName 'ITLAB' -InstallDNS -Force` — Creó el bosque y dominio `itlab.test`, instaló DNS y promovió Server. La contraseña DSRM se introdujo en un prompt seguro.
5. `Start-Transcript -Path 'C:\Lab-Evidence\LAB-03-server-setup.log' -Append` — Reanudó el registro tras el reinicio de la promoción.
6. `whoami` — Confirmó el inicio de sesión como `itlab\administrador`.
7. `Get-ADDomain | Select-Object DNSRoot,NetBIOSName,PDCEmulator` — Verificó `itlab.test`, `ITLAB` y `SERVER-LAB.itlab.test`.
8. `Get-Service NTDS,DNS | Select-Object Name,Status` — Confirmó ambos servicios en estado `Running`.
9. `Resolve-DnsName -Name '_ldap._tcp.dc._msdcs.itlab.test' -Type SRV -Server '10.77.30.10' | Select-Object NameTarget,Port` — Verificó que DNS publicaba el controlador LDAP `server-lab.itlab.test` en el puerto `389`.
10. `dcdiag /test:Advertising /test:SysVolCheck` — Confirmó que el controlador se anunciaba y SYSVOL estaba listo; también pasó la comprobación inicial de conectividad.
11. `Get-SmbShare -Name SYSVOL,NETLOGON | Select-Object Name,Path` — Confirmó ambos recursos compartidos del dominio.

### SERVER · Unidades organizativas

1. `New-ADOrganizationalUnit -Name 'Soporte-Lab' -Path 'DC=itlab,DC=test' -Description 'Objetos de practica de soporte TI'` — Creó la OU raíz para los objetos de práctica.
2. `'Usuarios','Grupos','Equipos' | ForEach-Object { New-ADOrganizationalUnit -Name $_ -Path 'OU=Soporte-Lab,DC=itlab,DC=test' }` — Creó tres OU hijas.
3. `Get-ADOrganizationalUnit -SearchBase 'OU=Soporte-Lab,DC=itlab,DC=test' -Filter * | Select-Object Name,DistinguishedName` — Comprobó la OU raíz y las tres hijas.

### ANFITRIÓN Y UBUNTU · Publicación de la etapa 1

1. **ANFITRIÓN:** `scp .\LAB-03-github-package.tar.gz mmuniz@172.21.53.73:/home/mmuniz/` — Copió a Ubuntu el paquete preparado con la nota, seis capturas y un script de verificación de solo lectura.
2. **UBUNTU:** `tar -xzf ~/LAB-03-github-package.tar.gz -C ~/it-support-labs` — Extrajo el paquete dentro del repositorio.
3. **UBUNTU:** `git -C ~/it-support-labs status --short` — Comprobó los ocho archivos nuevos.
4. **UBUNTU:** `git -C ~/it-support-labs add lab-notes/LAB-03-windows-server-ad-dns-foundation.md scripts/LAB-03-verify-foundation.ps1 evidence/LAB-03-*.png` — Preparó solo los archivos de esta etapa.
5. **UBUNTU:** `git -C ~/it-support-labs diff --cached --check` — Revisó errores de formato en los cambios preparados; no mostró errores.
6. **UBUNTU:** `git -C ~/it-support-labs diff --cached --stat` — Confirmó una nota, un script y seis imágenes.
7. **UBUNTU:** `git -C ~/it-support-labs commit -m "Document LAB-03 AD and DNS foundation"` — Registró la etapa 1 en el commit `2279f5a`.
8. **UBUNTU:** `git -C ~/it-support-labs push origin main` — Publicó el commit en GitHub.

**Resultado.** El dominio, DNS, NTDS, SYSVOL, NETLOGON y las cuatro OU iniciales quedaron verificados. El script `LAB-03-verify-foundation.ps1` fue preparado y publicado, pero **aún no se ejecutó** dentro de Server. Todavía faltan cuentas y grupos de AD, una GPO y la prueba desde un cliente unido al dominio; por eso LAB-03 está documentado como **etapa 1**.

---

## Estado general al cierre de esta transcripción

| Bloque | Estado comprobado |
| --- | --- |
| SETUP-01 | Git, repositorio público y acceso SSH desde Windows a Ubuntu configurados |
| LAB-00 | Sistema, actualizaciones ordinarias, SSH, ruta IP y DNS de Ubuntu comprobados |
| LAB-01 | Tres usuarios locales, dos grupos, carpeta compartida y ACL probados; IT-1 resuelto |
| LAB-02 | Nginx activo y respuesta HTTP 200 local y desde Windows; IT-2 resuelto |
| LAB-03, etapa 1 | Server instalado; `itlab.test`, AD DS, DNS, SYSVOL/NETLOGON y cuatro OU verificados; publicación en GitHub completada |

### Fuentes de verificación

- Notas públicas [SETUP-01](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/SETUP-01-repository-and-ssh.md), [LAB-00](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-00-ubuntu-support-lab-build-and-baseline.md), [LAB-01](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-01-local-users-groups-and-shared-access.md), [LAB-02](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-02-web-service-incident.md) y [LAB-03](https://github.com/moisesmunizcruz-web/it-support-labs/blob/main/lab-notes/LAB-03-windows-server-ad-dns-foundation.md).
- Registros revisados de LAB-01 y LAB-02, capturas compartidas durante la práctica y resultados de comandos de LAB-03.
- Esta bitácora no contiene registros brutos, contraseñas, tokens ni la salida íntegra de terminal.
