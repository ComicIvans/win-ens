# Script para adecuación al ENS en Sistemas Windows 10/11

Este repositorio contiene una colección de scripts de PowerShell diseñados para automatizar la **adecuación de equipos Windows 10 u 11** (independientes) al [Esquema Nacional de Seguridad](https://www.boe.es/buscar/doc.php?id=BOE-A-2022-7191) (ENS) y a la guía [CCN-STIC-599AB23](https://www.ccn-cert.cni.es/es/guias-de-acceso-publico-ccn-stic/7242-ccn-stic-599ab23-perfilado-de-seguridad-para-windows-cliente-cliente-miembro-o-cliente-independiente/file.html). El proyecto permite:

1. **Comprobar** si se cumplen los requisitos de seguridad.
2. **Aplicar** de forma automática dichos requisitos, en función de un perfil seleccionado.
3. **Restaurar** un estado previo de configuración, para revertir cambios en caso de incidencia.

La meta principal es que sea un sistema **modular, portátil y extensible**, en el que cada **grupo de políticas** y cada **perfil** dispongan de su propio directorio y lógica independiente.

Actualmente, los scrips solo trabajan con los mismos parámetros que comprueba la herramienta [CLARA](https://www.ccn-cert.cni.es/es/soluciones-seguridad/clara.html) para elaborar el informe de cumplimiento.

---

## Estructura General del Proyecto

La organización de ficheros y carpetas se basa en un enfoque modular que facilita añadir o quitar scripts. Los archivos y carpetas principales son:

- **Main.ps1**: Script principal (entry point).

  - Comprueba privilegios de administrador.
  - Pide al usuario la **acción** (Test/Set/Restore) y los **perfiles** a aplicar (p.ej. "Media-Estandar").
  - Lanza el script correspondiente del perfil elegido.

- **PrintsAndLogs.ps1**: Contiene funciones de **impresión** y **registro** (log):

  - `Show-Info`, `Show-Error`, `Show-Success` para mensajes con color y formato homogéneo.
  - `Save-GlobalInfo` para guardar metadatos en JSON.
  - `Show-TableRow` y `Show-TableHeader` para presentar tablas en consola, etc.

- **Perfiles**: Cada perfil de ENS ("Media_Estandar", "Alta_UsoOficial", etc.) tiene una carpeta y, dentro de esta:

  - **Main{Categoria}{Calificacion}.ps1**: controla la ejecución interna de ese perfil.
  - Subcarpetas con scripts para cada **grupo** de políticas: scripts de políticas concretas que implementan su propia lógica de **Test/Set/Restore**.

- **Logs/**: Directorio donde se almacenan:

  - Fichero `.log` con los mensajes de ejecución.
  - Fichero `.json` con el estado final (resultado de la acción, errores, etc.).

- **Backups/**: Directorio donde se almacenan copias de seguridad del sistema antes de aplicar cambios.

---

## Funcionamiento Paso a Paso

A continuación, un resumen de cómo se ejecuta y qué hace cada parte:

1. **Inicio (Main.ps1)**

   - Comprueba si somos **Administradores**. Si no, fuerza la elevación con `Start-Process -Verb RunAs`.
   - Limpia la consola y muestra un **menú** con las acciones disponibles:
     1. **Test**: Realizar comprobaciones de estado sin aplicar cambios.
     2. **Set**: Aplicar un perfil, modificando el sistema para que cumpla los requisitos.
     3. **Restore**: Restaurar la configuración previa a partir de una copia de seguridad.
   - En base a la selección, pide la **Categoría del sistema de información** y la **Calificación de la información**.
   - Genera las carpetas de **Logs** y **Backups** para la máquina actual y coloca en `$Global:LogFilePath` y `$Global:BackupFolderPath` las rutas concretas.

2. **Flujo Set / Test**

   - Si la acción elegida es **Test** o **Set**, se pregunta por la categoría del sistema de información (p.ej. "Media" o "Alta") y la calificación de la información (p.ej. "Estándar" o "UsoOficial").
   - Con esa información, compone un sufijo y llama, por ejemplo, a `Main_Media_Estandar.ps1`, que se ubica en la carpeta `Perfil_Media_Estandar`.
   - `Main_Media_Estandar.ps1` recorre sus subcarpetas y scripts (políticas concretas), ejecutando su función principal correspondiente.
     - Por ejemplo, en modo **Test**, llama a `Test-01_UAC_AdminPromptBehavior`, `Test-02_Ejemplo`, etc.
     - En modo **Set**, llama a `Set-01_UAC_AdminPromptBehavior`, etc. (estas funciones hacen backups y luego fijan valores de registro, directivas, etc.).

3. **Flujo Restore**

   - Si la acción elegida es **Restore**, Main.ps1 lista las **copias** del directorio "Backups\{MachineId}".
   - Permite al usuario seleccionar la carpeta de backup.
   - Deduce de su nombre qué perfil se aplicó originalmente (`Media_Estandar`, etc.).
   - Llama al script de perfil correspondiente con una variable `$Global:BackupFolderPath` apuntando a la carpeta de backup para restaurar los ajustes previos.

4. **Registro e Impresión**
   - Durante todo el proceso, se va guardando un log de texto y un fichero JSON con metadatos en “Logs\{MachineId}\{Timestamp}.log/json”.
   - Las funciones de `PrintsAndLogs.ps1` formatean la consola para una salida limpia, con encabezados, tablas y colores.
   - Los errores se guardan en `$Global:GlobalInfo.Error` y se escriben en el log.

---

## Cómo Empezar a Usarlo

1. **Descarga o clona** este repositorio en tu equipo.
2. **Ejecuta** `Main.ps1` con PowerShell **como Administrador** (o deja que el script fuerce la elevación).
   - Recuerda que si tu ExecutionPolicy bloquea scripts, puedes habilitar o pasar `-ExecutionPolicy Bypass` al lanzar PowerShell.
3. **El script** te pedirá la acción ("Test", "Set" o "Restore") y el **perfil** de seguridad (categoría del sistema de información y calificación de la información).
4. **Observa** cómo se generan las carpetas "Logs" y "Backups". Se guardarán registros y copias de seguridad ahí.
5. Revisa la **salida en pantalla** para ver la información de estado y las tablas de cada política que se comprueba o aplica.

---

## Cómo añadir nuevas políticas

Si deseas añadir un nuevo grupo de políticas, debes seguir los siguientes pasos:

1. **Crear** una subcarpeta dentro del perfil de destino (por ejemplo, `Perfil_Media_Estandar\OP_ACC_5`).
2. Dentro, poner un `Main_OP_ACC_5.ps1` con un objeto `Info` y la invocación a cada nueva política:
   ```powershell
   $OP_ACC_5_Info = [PSCustomObject]@{
       Name = 'OP.ACC.5'
       # ...
   }
   # Lógica para llamar a Test-XX, Set-XX, Restore-XX
   ```
3. Crear un script para cada política concreta (`01_PoliticaNueva.ps1`, etc.).
   - Incluir las funciones `Test-01_PoliticaNueva`, `Set-01_PoliticaNueva` y `Restore-01_PoliticaNueva`.
   - Cada función define la lógica correspondiente.

Si, por el contrario, solo deseas añadir un nuevo script a un grupo existente, puedes realizar el paso tres en la carpeta de ese grupo.

Es **muy recomendable** implementar los nuevos archivos a partir de una copia de los existentes, para asegurar que se sigue la misma estructura y se implementan todas las funciones y variables necesarias con sus nombres correspondientes.

---

## Trabajo pendiente

Los primero cambios a hacer son:

- Las copias de seguridad hay que gestionarlas de manera distinta, ya que al usar `reg export`, se guarda más información que el valor modificado, lo que causa que cuando varias políticas respaldan y modifican el mismo subárbol, se acaben sobreescribiendo y solo se restaure la última política aplicada.
- Al aplicar un perfil, se fuerzan los mínimos, sin comprobar si el sistema tenía una configuración más restrictiva, que debería darse por buena.
- Estudiar si se debe hacer una comprobación de que se haya creado el documento de respaldo antes de cambiar el valor en el registro.
- Al restaurar una copia de seguridad, que se revise el archivo de resultados `json` para saber hasta qué política restaurar y así evitar errores de archivos no encontrados correspondientes a políticas que no se llegaron a ejecutar.

Deespués, hay que terminar de añadir los scripts para cubrir todas las políticas de las categorías "Media" y "Alta" y las calificaciones "Estándar" y "Uso Oficial".

Una vez se complete eso, se estudiará la posibilidad de crear una aplicación de escritorio que permita un uso más amigable y muestre los resultados de forma más vistosa.
