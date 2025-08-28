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
  - **Templates.ps1**: Plantillas para validar objetos (configuración y varios tipos de `ProfileMeta`.).

- **Profiles/**: Carpeta que contiene todos los perfiles, sus grupos y sus políticas.

  - **Media_Estandar/**, **Alta_UsoOficial/**, etc.: Carpetas de perfiles con subcarpetas de grupos (por ejemplo, `OP_ACC_4`), que contienen los scripts de políticas (`01_*.ps1`, etc.).

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

   - `Main.ps1` llama a `Invoke-Profile` dentro de `ProfileExecutor.ps1`, que carga y ejecuta los grupos dentro del perfil llamando a `Invoke-Group`.
   - Cada grupo contiene varias políticas que se cargan y define el objeto `$PolicyMeta`, con información sobre cómo ejecutar dicha política.
   - Las políticas pueden recurrir a la lógica genérica disponible en `PolicyExecutor.ps1` o implementar sus propias funciones `Test-Policy`, `Set-Policy`, `Restore-Policy`, gestionando toda la ejecución.

3. **Flujo Test / Set / Restore**

   - En modo **Test**, se comprueba el estado de las políticas sin modificar el sistema.
   - En modo **Set**, se aplican los cambios y se crean backups previos.
   - En modo **Restore**, se restauran los valores desde una copia de seguridad seleccionada.

   Comportamiento no interactivo:

   - En **Test/Set**, si se pasa `-ProfileName`, se omite la selección de perfil y se ejecuta directamente ese perfil. Si no se pasa, se listan las carpetas de `Profiles/` para elegir.
   - En **Restore**, si se pasa `-BackupName`, se omite la selección de copia; si no, se listan las copias disponibles para la máquina. Si `-Action RestoreLast`, se restaura automáticamente la copia más reciente.

4. **Registro e impresión**
   - Todos los mensajes y resultados se registran en un archivo `.log` en la carpeta `Logs`.
   - El estado de ejecución del script general, su perfil, sus grupos y sus políticas se registra en un archivo `.json` en la carpeta `Logs`.
   - Los errores y estados se guardan en los objetos globales y se muestran en consola con formato y color.

---

## Cómo Empezar a Usarlo

1. **Descarga o clona** este repositorio en tu equipo.
2. **Ejecuta** `Main.ps1` con PowerShell **como Administrador** (o deja que el script fuerce la elevación).
   - Recuerda que si tu ExecutionPolicy bloquea scripts, puedes habilitar o pasar `-ExecutionPolicy Bypass` al lanzar PowerShell.
3. **El script** te pedirá la acción a realizar y, de ser necesario, el **perfil** a aplicar (categoría del sistema de información y calificación de la información). Si usas parámetros (ver sección "Ejecución no interactiva (CLI)"), el flujo puede ser completamente no interactivo.
4. **Observa** cómo se generan las carpetas "Logs" y "Backups". Se guardarán registros y copias de seguridad ahí.
5. Revisa la **salida en pantalla** para ver la información de la ejecución.

---

## Ejecución no interactiva (CLI)

`Main.ps1` admite ejecución por parámetros, todos opcionales, útil para automatización y scripts:

- `-Action`: `Test`, `Set`, `Restore` o `RestoreLast` (esta última restaura automáticamente la copia más reciente disponible para el equipo).
- `-ProfileName`: nombre exacto de la carpeta de perfil en `Profiles/` (p. ej., `Media_Estandar`, `Media_UsoOficial`). Si se especifica, se omite el menú de selección de perfil en `Test`/`Set`.
- `-BackupName`: nombre exacto de la carpeta de backup dentro de `Backups/<MachineId>/`. Si se especifica, se omite el menú de selección en `Restore`.
- `-ConfigFile`: ruta a un `config.json` alternativo. Por defecto `config.json`.
- `-Quiet`: evita la pausa final de "Presiona Enter para salir...".

---

## Aviso sobre las políticas sin valor establecido en los grupos OP_ACC_4 y OP_ACC_5

Al hacer pruebas con las políticas del tipo "Security", observamos un comportamiento inesperado: una vez se importa el archivo `secpol.cfg` (aunque el único cambio en el archivo sea el correspondiente al valor de la política ejecutándose), Windows le asigna un valor a todas las otras políticas que no tenían un valor configurado, tanto del grupo OP_ACC_4 como del OP_ACC_5.

Esto, por una parte, hace que al ajustar una política se estén modificando otras de forma accidental, pero lo más preocupante es que causa conflictos con las copias de seguridad:

- Si se está restaurando una copia de seguridad donde se está eliminando el valor de alguna política y después se restaura una política de seguridad, aquellas con el valor eliminado volverán a tener uno, haciendo inefectiva su restauración.
- Si se está ajustando un perfil, aquellas políticas sin valor configurado que se ejecuten después de una de seguridad no tendrán una copia de seguridad correcta por contener el valor que le haya asignado Windows al importar `secpol.cfg`.

No hay solución por el momento, por lo que si se ejecuta alguna de las políticas del tipo "Security" se debe tener en mente que no será posible, salvo que se anoten anteriormente las políticas sin valor configurado, restaurar el sistema a su estado anterior al completo.

---

## Cómo añadir nuevas políticas

Si deseas añadir un nuevo perfil, grupo de políticas o políticas a grupos existentes, debes seguir los siguientes pasos:

1. Para **crear un perfil**, comenzar creando una subcarpeta dentro de `Profiles\` (por ejemplo, `Profiles\Media_Estandar\`).
2. Dentro de esa carpeta **añadir un grupo**, creando una subcarpeta dentro de `Profiles\<Perfil>` (por ejemplo, `Profiles\Media_Estandar\OP_ACC_4`).
3. Crear un script para cada política concreta (`01_NuevaPolitica.ps1`, etc.) en la carpeta del grupo:
   - En caso de ser de un tipo soportado (comprobar las funciones de `PolicyExecutor.ps1`), definir únicamente su objeto `$PolicyMeta` con el tipo correspondiente y la información asociada a dicho tipo.
   - En caso de ser un tipo nuevo: o bien generalizar su ejecución mediante una nueva función de `PolicyExecutor.ps1` y su correspondiente llamada en `ProfileExecutor.ps1`, o bien especificar el tipo `Custom` dentro de `$PolicyMeta`, añadir la propiedad `IsValid = $null` e incluir las funciones `Initialize-Policy`, `Test-Policy`, `Backup-Policy`, `Set-Policy` y `Restore-Policy` dentro del archivo de la política. En este último caso, puede usarse de ejemplo `17_Pwd_ExpireEnabled.ps1` dentro de `OP_ACC_5` en `Media_Estandar`.

Es **muy recomendable** implementar los nuevos archivos a partir de una copia de los existentes, para asegurar que se sigue la misma estructura y se implementan todas variables necesarias con sus nombres y propiedades correspondientes. En caso de hacerse, asegurar que todo el contenido se actualice de acuerdo a la nueva política, sin referencias a la original.

---

## Trabajo en curso y pendiente

Se están añadiendo los scripts para cubrir todas las políticas de las categorías "Media" y "Alta" y las calificaciones "Estándar" y "Uso Oficial".
