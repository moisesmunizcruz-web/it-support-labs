# LAB-02: Habilitación y verificación de un servicio web en Ubuntu

- **Fecha:** 2026-09-17
- **Caso en Jira Service Management:** IT-2, `LAB-02 | Página web del laboratorio no disponible (simulado)`
- **Entorno:** VM personal `Ubuntu-Support-Lab` en Hyper-V; comprobaciones desde Ubuntu y Windows.
- **Alcance:** solicitud simulada de soporte TI, sin usuarios ni sistemas de producción.

## Solicitud y diagnóstico inicial

El objetivo era habilitar una página web de prueba en la VM, verificar que el servicio respondiera por HTTP desde Ubuntu y Windows, y documentar el resultado. Antes de instalar el servicio, `dpkg -s nginx` indicó que Nginx no estaba instalado y `systemctl status nginx --no-pager` devolvió `Unit nginx.service could not be found`. El archivo original de `script` comienza antes de esas pruebas y conserva sus salidas.

El diagnóstico mostraba la ausencia del paquete y de la unidad de servicio. No se probó una interrupción real de un sitio previamente operativo ni se midió el acceso HTTP desde Windows antes de la instalación.

## Acciones realizadas

1. Abrí IT-2 en Jira y lo pasé a **En curso**, con prioridad media. La descripción dejó claro que se trataba de una VM de laboratorio.
2. Registré la sesión de Ubuntu con `script`. El archivo original muestra una primera sesión ya activa durante el diagnóstico y, después, el comando `script -a ~/LAB-02-session.log` antes de instalar Nginx. El original quedó fuera del repositorio.
3. Ejecuté `sudo apt update` y `sudo apt install nginx`. La instalación terminó sin errores visibles y creó la unidad `nginx.service`.
4. `sudo systemctl status nginx --no-pager` mostró el servicio **active (running)** y **enabled**. `hostname -I` mostró `172.21.53.73` durante la prueba; esa dirección puede cambiar en una sesión futura.
5. El primer intento de `curl -I http://127.0.0.1/` mostró que `curl` no estaba instalado. Instalé la herramienta con `sudo apt install curl` y repetí la prueba. La respuesta fue `HTTP/1.1 200 OK`; el cuerpo de la página contenía `Welcome to nginx!`.
6. Desde Windows, `Test-NetConnection 172.21.53.73 -Port 80` devolvió `TcpTestSucceeded: True` y `Invoke-WebRequest -Uri "http://172.21.53.73/" -Method Head` devolvió `StatusCode: 200`. El navegador también mostró la página de bienvenida de Nginx en esa dirección.
7. `sudo nginx -t` confirmó que la sintaxis de `/etc/nginx/nginx.conf` era correcta y que la prueba de configuración fue exitosa. `systemctl is-enabled nginx` devolvió `enabled`. Cerré `script` con `exit`; la terminal mostró `Script finalizado`.
8. Cerré IT-2 en Jira como **Resuelta / Completado**, con una nota interna que resume la instalación y las pruebas HTTP desde ambos equipos.

## Resultado y límites

La VM sirve la página predeterminada de Nginx por HTTP, responde localmente y es accesible desde Windows por el puerto 80. El caso simulado quedó resuelto. La comprobación de Windows demuestra conectividad al puerto y respuesta HTTP en el momento de la prueba; no demuestra disponibilidad permanente. La página usa HTTP sin TLS, por lo que el navegador muestra «No seguro». No se configuró HTTPS ni una aplicación personalizada en este laboratorio.

## Evidencia

1. [IT-2 abierto y en curso](../evidence/LAB-02-jira-open.png).
2. [Diagnóstico inicial: Nginx ausente](../evidence/LAB-02-nginx-absent.png).
3. [Instalación de Nginx](../evidence/LAB-02-nginx-install.png).
4. [Servicio y respuesta HTTP local en Ubuntu](../evidence/LAB-02-ubuntu-http.png).
5. [Puerto 80 y respuesta HTTP 200 desde Windows](../evidence/LAB-02-windows-http.png).
6. [Página de Nginx abierta en el navegador de Windows](../evidence/LAB-02-windows-browser.png).
7. [Configuración válida, servicio habilitado y cierre de `script`](../evidence/LAB-02-final-check.png).
8. [IT-2 resuelto en Jira](../evidence/LAB-02-jira-resolved.png).

9. [Extracto revisado del registro de sesión](../evidence/LAB-02-session-reviewed.log).

El extracto se preparó a partir del archivo original de `script` y conserva los comandos y resultados relevantes. Se omitieron códigos de control, repeticiones de texto pegado y progreso animado de `apt`; estas omisiones se indican en el propio archivo. El original no se publicó. Las comprobaciones de Windows se hicieron fuera de la sesión de Ubuntu y están respaldadas por las capturas respectivas.

## Aprendizaje

Separé la ausencia del paquete, el estado de `systemd`, la respuesta HTTP local y el acceso desde otro equipo. La instalación activó el servicio, pero la validación exigió comprobar cada capa por separado. También corregí una dependencia de la prueba: `curl` faltaba inicialmente y fue instalado antes de obtener la respuesta HTTP local.
