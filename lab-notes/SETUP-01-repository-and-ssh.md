# SETUP-01: Repositorio y acceso SSH

**Fecha:** 2026-09-16

## Objetivo

Preparar un repositorio público para documentar prácticas simuladas de soporte TI y establecer una conexión de terminal desde Windows hacia Ubuntu.

## Contexto

El laboratorio usa Windows 11 Pro como host y la VM `Ubuntu-Support-Lab` con Ubuntu Desktop LTS en Hyper-V. La VM usa Default Switch con acceso a Internet mediante NAT.

## Pasos realizados

1. Comprobé que Git no estaba instalado con `git --version`.
2. Actualicé la lista de paquetes con `sudo apt update`, instalé Git con `sudo apt install git` y verifiqué `git version 2.53.0`.
3. Creé el repositorio público `it-support-labs` en GitHub y lo cloné en Ubuntu con `git clone`.
4. Creé las carpetas `lab-notes/`, `support-cases/`, `knowledge-base/` y `evidence/`.
5. Configuré Git para usar la dirección `noreply` proporcionada por GitHub en los commits futuros.
6. Instalé `openssh-server` y comprobé que `ssh.socket` estaba activo.
7. Me conecté desde Windows Terminal a Ubuntu mediante SSH y edité `README.md` con `nano`.

## Resultado y validación

Git funciona en Ubuntu y el acceso SSH desde Windows Terminal se realizó correctamente. Revisé los cambios del README con `git diff -- README.md`. El README y esta nota aún están pendientes de commit.

## Evidencia

Revisé las salidas de terminal y capturas durante la práctica. No he agregado capturas al repositorio; algunas muestran datos personales y requieren depuración antes de publicarse.

## Qué aprendí

Distinguí entre la consola de Hyper-V y una sesión SSH abierta desde Windows Terminal. También comprobé que `inactive` por sí solo no confirmaba que el servicio SSH estuviera instalado: el mensaje `Unit ssh.service not found` permitió identificar la causa.

## Pendiente

Revisar las actualizaciones y el reinicio indicado por Ubuntu durante `LAB-00`. Preparar Jira Service Management para los casos simulados.
