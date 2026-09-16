# SETUP-01: Repositorio y acceso SSH

**Fecha:** 2026-09-16  
**Tipo:** preparación de laboratorio personal; no es un caso de soporte a usuarios reales.

## Objetivo

Preparar un repositorio público para documentar prácticas simuladas de soporte TI y trabajar en la terminal de Ubuntu desde Windows.

## Contexto

El host usa Windows 11 Pro con Hyper-V. La VM `Ubuntu-Support-Lab` ejecuta Ubuntu Desktop LTS y tiene acceso a Internet mediante el Default Switch de Hyper-V. El repositorio público es `it-support-labs`.

## Diagnóstico y pasos realizados

1. **Comprobación de Git.** Ejecuté `git --version` en Ubuntu. La terminal indicó que Git no estaba instalado. Usé `sudo apt update` para actualizar la lista de paquetes y `sudo apt install git` para instalarlo. Una nueva ejecución de `git --version` mostró `git version 2.53.0`.

2. **Repositorio y estructura.** Creé el repositorio público en GitHub con un README inicial. Usé `git clone` para obtenerlo en Ubuntu. Creé `lab-notes/`, `support-cases/`, `knowledge-base/` y `evidence/`. Añadí archivos `.gitkeep` para que Git pudiera registrar las carpetas vacías y comprobé los archivos pendientes con `git status`.

3. **Identidad de Git.** Configuré la dirección `noreply` proporcionada por GitHub para evitar publicar mi correo personal en futuros commits. Verifiqué la dirección efectiva con `git config user.email`. No incluí la dirección personal ni credenciales en los archivos del portafolio.

4. **Problema al usar la terminal desde Windows.** La consola gráfica de Hyper-V no compartía el portapapeles de Windows con Ubuntu. Decidí usar SSH para trabajar desde Windows Terminal, donde pude pegar texto y ampliar la ventana.

5. **Diagnóstico de SSH.** `systemctl is-active ssh` respondió `inactive`. Probé `sudo systemctl start ssh`, pero el resultado fue `Unit ssh.service not found`. Ese error indicó que faltaba el servidor SSH, por lo que instalé `openssh-server` con `sudo apt install openssh-server`.

6. **Validación de SSH y red.** `systemctl is-active ssh.socket` respondió `active`. `ip -4 -brief address` mostró una dirección privada en `eth0`. Desde Windows Terminal utilicé `ssh mmuniz@<IP_DE_LA_VM>` y obtuve el prompt de Ubuntu. La dirección de la VM puede cambiar, por lo que no la trato como una configuración permanente.

7. **Documentación y publicación.** Edité el README bilingüe con `nano` desde la sesión SSH. Revisé los cambios con `git diff -- README.md`, agregué los archivos a Git y creé el commit `docs: add initial portfolio structure and disclaimer`. `git push origin main` publicó el commit y comprobé que la nota aparece en la vista web del repositorio.

## Resultado y validación

Git está instalado en Ubuntu, las cuatro carpetas aparecen en GitHub y la conexión SSH desde Windows Terminal funciona. La vista pública muestra el README y esta nota. El historial de Git registra los archivos publicados, no una transcripción automática de la consola.

## Evidencia y privacidad

Revisé salidas y capturas durante la práctica. Aún no publiqué capturas en `evidence/`; primero debo quitar datos personales y secretos. La credencial temporal usada para el primer push fue revocada y comprobé que su entrada ya no aparece en el historial guardado de Bash.

## Qué aprendí

Un resultado `inactive` no demostraba por sí solo que el servicio estuviera instalado; el mensaje `Unit ssh.service not found` cambió el diagnóstico. Aprendí la diferencia entre la consola de Hyper-V, una sesión SSH y el historial de archivos que Git publica.

## Pendiente

Revisar las actualizaciones y el reinicio indicado por Ubuntu en `LAB-00`. Preparar Jira Service Management para tickets simulados y añadir evidencia depurada.
