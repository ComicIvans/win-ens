# WIN-ENS

Este repositorio contiene una colección de scripts de PowerShell diseñados para automatizar la **adecuación de equipos Windows 10 u 11** (independientes, que no formen parte de un dominio) al [Esquema Nacional de Seguridad](https://www.boe.es/buscar/doc.php?id=BOE-A-2022-7191) (ENS) y a la guía [CCN-STIC-599AB23](https://www.ccn-cert.cni.es/es/guias-de-acceso-publico-ccn-stic/7242-ccn-stic-599ab23-perfilado-de-seguridad-para-windows-cliente-cliente-miembro-o-cliente-independiente/file.html).

El proyecto permite:

1. **Comprobar** si se cumplen los requisitos de seguridad.
2. **Aplicar** de forma automática dichos requisitos, en función de un perfil seleccionado.
3. **Restaurar** un estado previo de configuración, para revertir cambios en caso de incidencia.

Se trata de un proyecto **modular, portátil y extensible**, en el que cada política puede disponer de una lógica independiente.

> Actualmente, los scripts solo trabajan con los mismos parámetros que comprueba la herramienta [CLARA](https://www.ccn-cert.cni.es/es/soluciones-seguridad/clara.html) para elaborar el informe de cumplimiento.

---

## Estructura General del Proyecto

La estructura se basa en un enfoque modular, con toda la lógica en la carpeta `Modules/` salvo el script principal (`Main.ps1`), que actúa como punto de entrada.

- **Main.ps1**: Script principal (entry point).

  - Comprueba privilegios de administrador y eleva si es necesario.
  - Inicializa configuración, directorios de logs y backups.
  - Soporta ejecución no interactiva por parámetros (CLI) y reenvía los parámetros al elevar privilegios.
  - Muestra el menú de acciones y, si procede, gestiona la selección del perfil.
  - Llama a `Invoke-Profile` de `ProfileExecutor.ps1` para ejecutar la lógica.

- **Modules/**: Carpeta que agrupa el resto de la lógica del proyecto:

  - **Config.ps1**: Gestión del archivo de configuración (`config.json` por defecto), detección y sincronización con la estructura real.
  - **PrintsAndLogs.ps1**: Funciones de impresión y registro con formato homogéneo y colores (`Show-Info`, `Show-Error`, `Show-Success`, etc.).
  - **Utils.ps1**: Funciones de utilidad, conversión y validación recursiva de objetos, guardado de archivos en disco (backups, info), etc.
  - **PolicyExecutor.ps1**: Lógica genérica para ejecutar tipos de políticas predeterminados.
  - **ProfileExecutor.ps1**: Orquesta la ejecución de perfiles completos recorriendo grupos y políticas.
  - **Templates.ps1**: Plantillas para validar objetos (configuración y varios tipos de `PolicyMeta`).

- **Profiles/**: Carpeta que contiene todos los perfiles, sus grupos y sus políticas.

  - **Media_Estandar/**, **Alta_UsoOficial/**, etc.: Carpetas de perfiles con subcarpetas de grupos (por ejemplo, `OP_ACC_4`), que contienen los scripts de políticas (`*.ps1`).  
    El orden de ejecución lo define el manifest `profile.manifest.json` de cada perfil.

- **Logs/**: Directorio donde se almacenan:

  - Archivos `.log` con los mensajes de ejecución.
  - Archivos `.json` con el estado final de la ejecución del perfil, sus grupos y sus políticas.
  - Archivos `.csv` con los resultados de la comprobación del sistema, en caso de que esté habilitado el guardado en la configuración.

- **Backups/**: Directorio donde se almacenan copias de seguridad del sistema antes de aplicar cambios, organizadas por máquina y perfil.

---

## Funcionamiento Paso a Paso

1. **Inicio (Main.ps1)**

   - Importa el resto de archivos.
   - Comprueba privilegios de administrador y eleva si es necesario.
   - Crea `$Global:Info`.
   - Inicializa la configuración y los directorios de logs/backups, comparando configuración con la estructura real de archivos y mostrando discrepancias.
   - Si se proporciona `-Action`, se omite el menú y se ejecuta directamente la acción indicada; en caso contrario, se muestra el menú y se gestiona la selección del usuario.

2. **Ejecución de perfiles y grupos**

   - `Main.ps1` llama a `Invoke-Profile` dentro de `ProfileExecutor.ps1`, que:
     - Inicializa todos los grupos y políticas definidos en el manifest.
     - Realiza copias de respaldo si la acción es `Set`.
     - Ejecuta la acción (`Test`, `Set` o `Restore`) sobre todos los grupos y políticas.
     - Valida los resultados en iteraciones sucesivas hasta que todas las políticas estén correctamente aplicadas/restauradas o se alcance el máximo configurado (`MaxValidationIterations`).

3. **Flujo Test / Set / Restore**

   - En modo **Test**, se comprueba el estado de las políticas sin modificar el sistema.
   - En modo **Set**, se aplican los cambios, creando backups previos, y se valida que los ajustes se apliquen correctamente con iteraciones.
   - En modo **Restore**, se restauran los valores desde una copia de seguridad seleccionada y se valida que las políticas recuperen su valor original.
   - En ejecución no interactiva:
     - En **Test/Set**, si se pasa `-ProfileName`, se omite la selección de perfil.
     - En **Restore**, si se pasa `-BackupName`, se omite la selección de copia; con `-Action RestoreLast` se restaura automáticamente la más reciente.

4. **Registro e impresión**
   - Todos los mensajes y resultados se registran en un archivo `.log`.
   - El estado de ejecución general, perfiles, grupos y políticas se registra en un `.json`.
   - En modo **Test**, los resultados pueden guardarse en `.csv` si está habilitado en la configuración.
   - Los mensajes en pantalla usan colores y un formato homogéneo.

---

## Cómo Empezar a Usarlo

1. **Descarga o clona** este repositorio.
2. **Ejecuta** `Main.ps1` con PowerShell **como Administrador** (o deja que el script fuerce la elevación).
3. Selecciona la acción y el perfil a aplicar, o usa parámetros para ejecución no interactiva.
4. Consulta las carpetas `Logs` y `Backups` para ver resultados y copias.
5. Revisa la salida en pantalla para seguir la ejecución.

---

## Ejecución no interactiva (CLI)

Parámetros disponibles en `Main.ps1`:

- `-Action`: `Test`, `Set`, `Restore` o `RestoreLast`.
- `-ProfileName`: nombre de la carpeta de perfil en `Profiles/`.
- `-BackupName`: nombre exacto de la carpeta en `Backups/<MachineId>/`.
- `-ConfigFile`: ruta alternativa a `config.json`.
- `-Quiet`: evita la pausa final.

---

## Orden de ejecución de grupos y políticas

El orden lo define el archivo `Profiles/<Perfil>/profile.manifest.json`.  
El manifest se sincroniza automáticamente: conserva el orden existente, añade nuevas entradas al final (orden alfabético entre nuevas) y elimina las que ya no existan.

---

## Cómo añadir nuevas políticas

1. Crear carpeta de perfil en `Profiles/` si es necesario.
2. Crear carpeta de grupo dentro del perfil.
3. Añadir script `.ps1` de la política dentro del grupo:
   - Si es un tipo soportado por `PolicyExecutor.ps1`, definir solo el objeto `$PolicyMeta`.
   - Si es un tipo nuevo, usar tipo `Custom` en `$PolicyMeta` e implementar funciones `Initialize-Policy`, `Test-Policy`, `Backup-Policy`, `Set-Policy`, `Restore-Policy` y `Assert-Policy`.
4. Asegurar que el nombre del archivo coincide con `$PolicyMeta.Name`.
5. Añadir la política al manifest `profile.manifest.json` para definir su orden.
