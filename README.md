# WIN-ENS

Este repositorio contiene una colección de scripts de PowerShell diseñados para automatizar la **adecuación de equipos Windows 10 u 11** (independientes) al [Esquema Nacional de Seguridad](https://www.boe.es/buscar/doc.php?id=BOE-A-2022-7191) (ENS) y a la guía [CCN-STIC-599AB23](https://www.ccn-cert.cni.es/es/guias-de-acceso-publico-ccn-stic/7242-ccn-stic-599ab23-perfilado-de-seguridad-para-windows-cliente-cliente-miembro-o-cliente-independiente/file.html). El proyecto permite:

1. **Comprobar** si se cumplen los requisitos de seguridad.
2. **Aplicar** de forma automática dichos requisitos, en función de un perfil seleccionado.
3. **Restaurar** un estado previo de configuración, para revertir cambios en caso de incidencia.

La meta principal es que sea un sistema **modular, portátil y extensible**, en el que cada **grupo de políticas** y cada **perfil** dispongan de su propio directorio y lógica independiente.

Actualmente, los scripts solo trabajan con los mismos parámetros que comprueba la herramienta [CLARA](https://www.ccn-cert.cni.es/es/soluciones-seguridad/clara.html) para elaborar el informe de cumplimiento.

---

## Estructura General del Proyecto

La organización de ficheros y carpetas se basa en un enfoque modular que facilita añadir o quitar scripts. Los archivos y carpetas principales son:

- **Main.ps1**: Script principal (entry point).

  - Comprueba privilegios de administrador.
  - Muestra un menú de acciones (Test/Set/Restore/Config).
  - Solicita la categoría y calificación del sistema.
  - Lanza el script correspondiente del perfil elegido.

- **PrintsAndLogs.ps1**: Funciones de impresión y registro (log), con formato homogéneo y colores.

  - `Show-Info`, `Show-Error`, `Show-Success`, `Show-TableRow`, `Show-TableHeader`, etc.
  - Registro de mensajes y metadatos en archivos `.log` y `.json`.

- **Config.ps1**: Funciones para la gestión y validación de la configuración global.

  - Carga y comparación de la configuración (`config.json`) con la estructura real de perfiles, grupos y políticas.
  - Detección y visualización de discrepancias.
  - Fusión y actualización de grupos de políticas.

- **Utils.ps1**: Funciones de utilidad para el resto de los archivos, como la conversión recursiva de objetos a hashtables (con opción de ordenación) y las funciones encargadas de guardar archivos en disco (backups, info).

- **Perfiles**: Cada perfil ENS ("Media_Estandar", "Alta_UsoOficial", etc.) tiene su propia carpeta:

  - **Main*{Categoria}*{Calificacion}.ps1**: Define el objeto de perfil y ejecuta los grupos.
  - Subcarpetas para cada grupo de políticas, con su propio script principal (`Main_{Grupo}.ps1`) y scripts de políticas concretas (`01_UAC_AdminPromptBehavior.ps1`, etc.).

- **Logs/**: Directorio donde se almacenan:

  - Archivos `.log` con los mensajes de ejecución.
  - Archivos `.json` con el estado final y metadatos.

- **Backups/**: Directorio donde se almacenan copias de seguridad del sistema antes de aplicar cambios, organizadas por máquina y perfil.

---

## Funcionamiento Paso a Paso

1. **Inicio (Main.ps1)**

   - Comprueba privilegios de administrador y eleva si es necesario.
   - Inicializa la configuración y los directorios de logs/backups.
   - Muestra el menú de acciones y gestiona la selección del usuario.

2. **Verificación de la configuración**

   - Carga la configuración global desde `config.json` (o la crea si no existe).
   - Compara la configuración con la estructura real de archivos y muestra discrepancias.
   - Permite fusionar y actualizar la configuración según los cambios detectados.

3. **Ejecución de perfiles y grupos**

   - Main.ps1 llama al script principal del perfil seleccionado (`Main_{Categoria}_{Calificacion}.ps1`).
   - El script del perfil define el objeto `$ProfileInfo` y recorre sus subcarpetas, llamando al script principal de cada grupo (`Main_{Grupo}.ps1`).
   - Cada grupo define su objeto `$GroupInfo` y ejecuta sus políticas mediante scripts independientes.
   - Las políticas implementan funciones `Test-Policy`, `Set-Policy`, `Restore-Policy` y gestionan su propio estado y backups.

4. **Flujo Test / Set / Restore**

   - En modo **Test**, se comprueba el estado de las políticas sin modificar el sistema.
   - En modo **Set**, se aplican los cambios y se crean backups previos.
   - En modo **Restore**, se restauran los valores desde una copia de seguridad seleccionada.

5. **Registro e impresión**
   - Todos los mensajes y resultados se registran en archivos `.log` y `.json` en la carpeta `Logs`.
   - Los errores y estados se guardan en los objetos globales y se muestran en consola con formato y color.

---

## Cómo Empezar a Usarlo

1. **Descarga o clona** este repositorio en tu equipo.
2. **Ejecuta** `Main.ps1` con PowerShell **como Administrador** (o deja que el script fuerce la elevación).
   - Recuerda que si tu ExecutionPolicy bloquea scripts, puedes habilitar o pasar `-ExecutionPolicy Bypass` al lanzar PowerShell.
3. **El script** te pedirá la acción y el **perfil** de seguridad (categoría del sistema de información y calificación de la información).
4. **Observa** cómo se generan las carpetas "Logs" y "Backups". Se guardarán registros y copias de seguridad ahí.
5. Revisa la **salida en pantalla** para ver la información de estado y las tablas de cada política que se comprueba o aplica.

---

## Cómo añadir nuevas políticas

Si deseas añadir un nuevo grupo de políticas, debes seguir los siguientes pasos:

1. **Crear** una subcarpeta dentro del perfil de destino (por ejemplo, `Media_Estandar\OP_ACC_5`).
2. Dentro, poner un `Main_OP_ACC_5.ps1` con un objeto `GroupInfo` y la invocación a cada nueva política:
   ```powershell
   $GroupInfo = [PSCustomObject]@{
       Name = 'OP_ACC_5'
       # ...
   }
   # Lógica para llamar a Test-Policy, Set-Policy, Restore-Policy
   ```
3. Crear un script para cada política concreta (`01_PoliticaNueva.ps1`, etc.).
   - Incluir las funciones `Test-Policy`, `Set-Policy` y `Restore-Policy`.
   - Cada función define la lógica correspondiente.

Si, por el contrario, solo deseas añadir un nuevo script a un grupo existente, puedes realizar el paso tres en la carpeta de ese grupo.

Es **muy recomendable** implementar los nuevos archivos a partir de una copia de los existentes, para asegurar que se sigue la misma estructura y se implementan todas las funciones y variables necesarias con sus nombres correspondientes.

---

## Trabajo pendiente

Los primero cambios a hacer son:

- Al aplicar un perfil, se fuerzan los mínimos, sin comprobar si el sistema tenía una configuración más restrictiva, que debería darse por buena.
- Añadir alternativas a la ejecución interactiva como la ejecución mediante parámetros.

Después, hay que terminar de añadir los scripts para cubrir todas las políticas de las categorías "Media" y "Alta" y las calificaciones "Estándar" y "Uso Oficial".

Una vez se complete eso, se estudiará la posibilidad de crear una aplicación de escritorio que permita un uso más amigable y muestre los resultados de forma más vistosa.
