# LAB-01: Cuentas locales, grupos y acceso compartido en Ubuntu

**Fecha:** 2026-09-16  
**Caso en Jira Service Management:** IT-1, `LAB-01 | Alta de cuentas y grupos en Ubuntu (simulado)`  
**Entorno:** VM personal `Ubuntu-Support-Lab` en Hyper-V, administrada por SSH desde Windows Terminal.  
**Alcance:** práctica simulada. No corresponde a empleados, clientes ni sistemas de producción.

## Solicitud y objetivo

Crear tres cuentas locales de prueba en Ubuntu y dos grupos para un equipo ficticio de soporte. `agente01` y `agente02` deben pertenecer a `soporte_l1`; `supervisor01` debe pertenecer a `soporte_l1` y `supervisores_ti`. Cada cuenta debe tener una contraseña propia. Después se debe comprobar la autenticación y el acceso a una carpeta compartida, incluida una prueba de acceso denegado.

**Impacto y prioridad simulados:** incorporación de tres integrantes al entorno de práctica; prioridad media registrada en Jira. No hubo interrupción de un servicio real ni se aplicó un SLA real.

## Herramientas y registro

- En Windows, usé el navegador para crear y seguir la solicitud IT-1 en Jira Service Management. Usé Windows Terminal para conectarme por SSH a Ubuntu y PowerShell para transferir las capturas al repositorio de la VM.
- En Ubuntu, inicié `script -q ~/LAB-01-session.log` antes de modificar cuentas y permisos. El registro original quedó fuera del repositorio. La [transcripción publicada](../evidence/LAB-01-session-reviewed.log) es una copia revisada para lectura pública; conserva comandos y resultados y elimina códigos de control de terminal.
- Las contraseñas se introdujeron mediante los diálogos interactivos de `adduser` y `su`. No se incluyeron sus valores en Jira, capturas, notas ni transcripción publicada.

## Diagnóstico y pasos realizados

### 1. Cuentas y grupos

1. `sudo addgroup soporte_l1` y `sudo addgroup supervisores_ti`: creé los dos grupos del escenario.
2. `sudo adduser agente01`, `sudo adduser agente02` y `sudo adduser supervisor01`: creé las cuentas y sus directorios personales. Cada alta solicitó una contraseña de forma interactiva; dejé vacíos los campos opcionales de perfil por tratarse de usuarios ficticios.
3. Durante el alta de `agente01`, Ubuntu rechazó un intento de contraseña por tener menos de ocho caracteres, otro por ser demasiado simple y hubo intentos cuya repetición no coincidió. Después, `passwd` confirmó que la contraseña quedó actualizada. Las otras dos altas también terminaron con esa confirmación. Esto documenta la respuesta observada del sistema, no una descripción completa de su política de contraseñas.
4. `sudo adduser agente01 soporte_l1`, `sudo adduser agente02 soporte_l1`, `sudo adduser supervisor01 soporte_l1` y `sudo adduser supervisor01 supervisores_ti`: asigné las membresías requeridas.
5. `id agente01`, `id agente02` e `id supervisor01`: confirmé los grupos. Los dos agentes figuran en `soporte_l1`; el supervisor figura en `soporte_l1` y `supervisores_ti`.

### 2. Acceso inicial a la carpeta

1. `sudo mkdir /srv/soporte_l1`: creé la carpeta de trabajo fuera del repositorio.
2. `sudo chown root:soporte_l1 /srv/soporte_l1`: asigné propietario `root` y grupo `soporte_l1`.
3. `sudo chmod 2770 /srv/soporte_l1`: permití acceso al propietario y al grupo, denegué acceso a otros y activé la herencia del grupo mediante setgid. `ls -ld /srv/soporte_l1` mostró `drwxrws---`.
4. Usé `sudo -u ... touch` para crear un archivo como cada una de las tres cuentas. Las tres operaciones funcionaron y los archivos heredaron el grupo `soporte_l1`.
5. Como `mmuniz`, intenté crear un archivo y listar la carpeta sin `sudo`. Ambas operaciones devolvieron «Permiso denegado», resultado esperado para una cuenta fuera de `soporte_l1`.

### 3. Autenticación con contraseñas

Entré por separado con `su - agente01`, `su - agente02` y `su - supervisor01`. En cada sesión, `whoami` devolvió el nombre esperado. Salí con `exit` antes de probar la siguiente cuenta. Estas pruebas confirman que se podía autenticar cada usuario con su contraseña; no revelan las contraseñas.

### 4. Permisos para editar archivos compartidos

Los primeros archivos se crearon con permisos `-rw-r--r--`: heredaron el grupo, pero otro miembro de `soporte_l1` no tenía permiso de escritura sobre ellos. El bit setgid de la carpeta solo resolvía la herencia del grupo.

1. `command -v setfacl` confirmó que la herramienta estaba disponible.
2. `sudo setfacl -d -m u::rwx,g::rwx,o::--- /srv/soporte_l1` estableció una ACL predeterminada para los objetos creados después. `sudo getfacl -d /srv/soporte_l1` confirmó las entradas de propietario, grupo y otros.
3. `sudo -u agente01 touch /srv/soporte_l1/compartido.txt` creó un archivo nuevo. `sudo ls -l` mostró `-rw-rw----` y el grupo `soporte_l1`.
4. `agente02` añadió la línea «Revisión realizada por agente02» mediante `tee -a` ejecutado como esa cuenta. `supervisor01` pudo leerla con `cat`.

**Límite observado:** la ACL predeterminada se aplica a archivos nuevos. Los tres archivos de prueba anteriores conservaron sus permisos originales `-rw-r--r--`.

## Resultado y validación

- Tres cuentas creadas; las tres contraseñas fueron probadas mediante inicio de sesión.
- Membresías correctas para ambos agentes y el supervisor.
- Los miembros del grupo pudieron crear archivos en `/srv/soporte_l1`; la cuenta ajena recibió «Permiso denegado».
- Un archivo creado después de configurar la ACL permitió escribir a un segundo agente y leer al supervisor.
- El caso quedó registrado en Jira como IT-1. La captura inicial muestra la solicitud antes de ejecutar el trabajo; la captura final confirma el estado **Resuelta** y la resolución **Completado**.

## Evidencia revisada

1. [Solicitud IT-1 creada en Jira](../evidence/LAB-01-jira-open.png).
2. [Usuarios y membresías de grupo](../evidence/LAB-01-users-groups.png).
3. [Carpeta, archivos y acceso denegado](../evidence/LAB-01-access-tests.png).
4. [Autenticación de las tres cuentas](../evidence/LAB-01-password-validation.png).
5. [ACL y edición compartida](../evidence/LAB-01-shared-edit-validation.png).
6. [Error de Jira al intentar resolver sin una opción de resolución](../evidence/LAB-01-jira-resolution-error.png).
7. [Caso IT-1 resuelto en Jira](../evidence/LAB-01-jira-resolved.png).
8. [Transcripción revisada de la sesión](../evidence/LAB-01-session-reviewed.log).

Las capturas y la transcripción se revisaron antes de publicarse. Las imágenes muestran las pruebas realizadas; el historial de Git registra los archivos publicados, no cada pulsación de teclado.

## Escalamiento y aprendizaje

No se requirió escalamiento: las comprobaciones de autenticación y permisos finalizaron dentro del laboratorio. Aprendí a diferenciar la membresía de grupo, el acceso a una carpeta, el permiso de escritura sobre archivos existentes y los permisos que heredan los archivos nuevos. También comprobé que un rechazo de contraseña durante el alta no impide completar la cuenta con una contraseña aceptada posteriormente.

Al cerrar IT-1, Jira exigió una resolución, pero la lista de opciones estaba vacía. En la administración de **Actividades → Resoluciones**, añadí `Completado` con la descripción «La solicitud se atendió y se verificó el resultado». Después repetí la transición y confirmé **Resuelta · Completado**. Esa configuración es general de Jira; la incidencia y su solución también forman parte del aprendizaje del laboratorio.
