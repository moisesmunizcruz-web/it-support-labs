# LAB-00: Preparación y comprobación del laboratorio

**Fecha:** 2026-09-16  
**Tipo:** laboratorio personal y simulado; no representa experiencia en producción ni atención a usuarios reales.

## Objetivo

Comprobar desde Windows y Ubuntu que la máquina virtual, el acceso SSH, las actualizaciones y la red están listos para los ejercicios de soporte TI.

## Entorno

- **Anfitrión:** Windows 11 Pro con Hyper-V.
- **Máquina virtual:** `Ubuntu-Support-Lab`, generación 2, 4 procesadores y 8 GiB de memoria asignada.
- **Sistema invitado:** Ubuntu 26.04.1 LTS.
- **Red virtual:** `Default Switch` de Hyper-V.
- **Acceso de trabajo:** Windows Terminal mediante SSH hacia Ubuntu.

## Comprobaciones en Windows

Abrí PowerShell y ejecuté `Get-VM` y `Get-VMNetworkAdapter` para revisar el estado de la VM y su conexión al conmutador virtual. La primera ejecución devolvió un error de permisos. Repetí las consultas desde PowerShell abierto como administrador: la VM apareció en estado `Running` y el adaptador conectado a `Default Switch` mostró estado `Ok`.

## Comprobaciones en Ubuntu

- `hostnamectl` identificó Ubuntu 26.04.1 LTS ejecutándose como máquina virtual de Hyper-V.
- `df -h /` mostró 58 GB en el sistema de archivos raíz, 11 GB usados y 45 GB disponibles.
- `sudo apt update` actualizó la lista de paquetes y detectó 17 actualizables.
- `sudo apt upgrade` actualizó 9 paquetes. Otros 8 permanecieron pendientes por la distribución gradual de actualizaciones de Ubuntu; no forcé su instalación.
- Reinicié Ubuntu con `sudo reboot`. La conexión SSH se interrumpió durante el reinicio y después pude volver a conectarme desde Windows Terminal usando la misma dirección de la VM, sin abrir su consola gráfica.
- Tras reconectarme, `systemctl is-active ssh.socket` respondió `active`.

## Comprobación de red

- `ip -4 -brief address` mostró `eth0` activa con la dirección privada `172.21.53.73/20`.
- `ip route` mostró una ruta predeterminada por `172.21.48.1` a través de `eth0`.
- `ping -c 3 1.1.1.1` recibió 3 de 3 respuestas, con 0 % de pérdida.
- `resolvectl query ubuntu.com` devolvió direcciones para el dominio, confirmando que la resolución DNS funcionó.

## Resultado

La VM está operativa, el acceso SSH funciona después de reiniciar y Ubuntu puede salir a la red y resolver nombres. El laboratorio está listo para continuar con ejercicios de usuarios, grupos y permisos.

## Evidencia

## Evidencia

- [Estado de la VM y del adaptador en Windows](../evidence/LAB-00-windows-hyper-v.png).
- [Comprobaciones de red desde Ubuntu](../evidence/LAB-00-ubuntu-network.png).

La grabación completa de terminal permanece en `~/LAB-00-session.log`, fuera del repositorio, para revisarla antes de publicar cualquier extracto.

## Aprendizaje

Una consulta de Hyper-V puede fallar por permisos aunque la VM funcione correctamente. También comprobé por separado la dirección de red, la ruta de salida, la conectividad IP y la resolución DNS: cada prueba confirma una parte distinta de la conexión.
