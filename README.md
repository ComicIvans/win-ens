# WIN-ENS

Este repositorio contiene una colección de scripts de PowerShell diseñados para automatizar la **adecuación de equipos Windows 10 u 11** (independientes) al [Esquema Nacional de Seguridad](https://www.boe.es/buscar/doc.php?id=BOE-A-2022-7191) (ENS) y a la guía [CCN-STIC-599AB23](https://www.ccn-cert.cni.es/es/guias-de-acceso-publico-ccn-stic/7242-ccn-stic-599ab23-perfilado-de-seguridad-para-windows-cliente-cliente-miembro-o-cliente-independiente/file.html). El proyecto permite:

1. **Comprobar** si se cumplen los requisitos de seguridad.
2. **Aplicar** de forma automática dichos requisitos, en función de un perfil seleccionado.
3. **Restaurar** un estado previo de configuración, para revertir cambios en caso de incidencia.

La meta principal es que sea un sistema **modular, portátil y extensible**, en el que cada **grupo de políticas** y cada **perfil** dispongan de su propio directorio y lógica independiente.

_Actualmente, los scripts solo trabajan con los mismos parámetros que comprueba la herramienta [CLARA](https://www.ccn-cert.cni.es/es/soluciones-seguridad/clara.html) para elaborar el informe de cumplimiento._

---

## Estructura General del Proyecto

La organización de ficheros y carpetas se basa en un enfoque modular, con todo el código centralizado en la carpeta `Modules/` excepto por `Main.ps1`, el punto de entrada.

- **Main.ps1**: Script principal (entry point).

  - Comprueba privilegios de administrador y eleva si es necesario.
  - Inicializa configuración, directorios de logs y backups.
  - Muestra menú de acciones (Test/Set/Restore/Config) y gestiona la selección de perfil.
  - Llama a la correspondiente función en `Modules/ProfileExecutor.ps1` para continuar con la lógica.

- **Modules/**: Carpeta que agrupa la lógica modular del proyecto:

  - **Config.ps1**: Gestión y validación de configuración global (`config.json`), detección de discrepancias y actualización.
  - **PrintsAndLogs.ps1**: Funciones de impresión y registro con formato homogéneo y colores (`Show-Info`, `Show-Error`, `Show-Success`, etc.).
  - **Utils.ps1**: Funciones de utilidad, conversión y validación recursiva de objetos, guardado de archivos en disco (backups, info), etc.
  - **PolicyExecutor.ps1**: Lógica genérica para ejecutar tipos de políticas comunes (Test/Set/Restore).
  - **ProfileExecutor.ps1**: Orquesta la ejecución de perfiles completos recorriendo grupos y políticas.
  - **Templates.ps1**: Plantillas para validar objetos (configuración, `GroupInfo`, `ProfileInfo`, etc.).
  - **Media_Estandar/**, **Alta_UsoOficial/**, etc.: Carpetas de perfiles con un `Main_{Perfil}.ps1` y subcarpetas de grupos (por ejemplo, `OP_ACC_4`), que contienen un `Main_{Grupo}.ps1` y los scripts de políticas (`01_*.ps1`, etc.).

- **Logs/**: Directorio donde se almacenan:

  - Archivos `.log` con los mensajes de ejecución.
  - Archivos `.json` con el estado final de la ejecución del perfil, sus grupos y sus políticas.

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

   - `Main.ps1` llama a `Invoke-Profile` dentro de `ProfileExecutor`, que carga el script principal del perfil seleccionado (`Main_{Categoria}_{Calificacion}.ps1`).
   - El script del perfil define el objeto `$ProfileInfo` y por cada subcarpeta (grupo) se carga el script principal de cada grupo (`Main_{Grupo}.ps1`), que define el objeto `$GroupInfo`.
   - Cada grupo contiene varias políticas que definen los objetos `$PolicyInfo` y `$PolicyMeta`. Este último servirá para indicarle al script cómo ejecutar dicha política.
   - Las políticas pueden recurrir a la lógica genérica disponible o implementar sus propias funciones `Test-Policy`, `Set-Policy`, `Restore-Policy`, gestionando toda la ejecución.

4. **Flujo Test / Set / Restore**

   - En modo **Test**, se comprueba el estado de las políticas sin modificar el sistema.
   - En modo **Set**, se aplican los cambios y se crean backups previos.
   - En modo **Restore**, se restauran los valores desde una copia de seguridad seleccionada.

5. **Registro e impresión**
   - Todos los mensajes y resultados se registran en un archivo `.log` en la carpeta `Logs`.
   - El estado de ejecución del script general, su perfil, sus grupos y sus políticas se registra en un archivo `.json` en la carpeta `Logs`.
   - Los errores y estados se guardan en los objetos globales y se muestran en consola con formato y color.

---

## Cómo Empezar a Usarlo

1. **Descarga o clona** este repositorio en tu equipo.
2. **Ejecuta** `Main.ps1` con PowerShell **como Administrador** (o deja que el script fuerce la elevación).
   - Recuerda que si tu ExecutionPolicy bloquea scripts, puedes habilitar o pasar `-ExecutionPolicy Bypass` al lanzar PowerShell.
3. **El script** te pedirá la acción a realizar y, de ser necesario, el **perfil** a aplicar (categoría del sistema de información y calificación de la información).
4. **Observa** cómo se generan las carpetas "Logs" y "Backups". Se guardarán registros y copias de seguridad ahí.
5. Revisa la **salida en pantalla** para ver la información de la ejecución.

---

## Cómo añadir nuevas políticas

Si deseas añadir un nuevo perfil, grupo de políticas o políticas a grupos existentes, debes seguir los siguientes pasos:

1. Para **crear un perfil**, comenzar creando una subcarpeta dentro de `Modules\` (por ejemplo, `Modules\Media_Estandar\`).
2. Dentro de esa carpeta, crear el script `Main_<Perfil>.ps1` con su correspondiente objeto `$ProfileInfo` (por ejemplo, `Modules\Media_Estandar\Main_Media_Estandar.ps1`).
3. Para **crear un grupo**, crear una subcarpeta dentro de `Modules\<Perfil>` (por ejemplo, `Modules\Media_Estandar\OP_ACC_4`).
4. Dentro de esa carpeta, crear el script `Main_<Grupo>.ps1` con su correspondiente objeto `$GroupInfo` (por ejemplo, `Modules\Media_Estandar\OP_ACC_4\Main_OP_ACC_4.ps1`).
5. Crear un script para cada política concreta (`01_NuevaPolitica.ps1`, etc.) en la misma carpeta:
   - En caso de ser de un tipo soportado (comprobar las funciones de `PolicyExecutor.ps1`), definir únicamente su objeto `$PolicyInfo` con el tipo correspondiente y la información asociada a dicho tipo.
   - En caso de ser un tipo nuevo, o generalizar su ejecución mediante una nueva función de `PolicyExecutor.ps1` y su correspondiente llamada en `ProfileExecutor.ps1`, o especificar el tipo `Custom` e incluir las funciones `Test-Policy`, `Set-Policy` y `Restore-Policy` dentro del archivo dela política. En este último caso, asegurarse de implementar una lógica lo más similar posible a las ya existentes en `PolicyExecutor.ps1`.

Es **muy recomendable** implementar los nuevos archivos a partir de una copia de los existentes, para asegurar que se sigue la misma estructura y se implementan todas variables necesarias con sus nombres y propiedades correspondientes. En caso de hacerse, asegurar que todo el contenido se actualice de acuerdo a la nueva política, sin referencias a la original.

---

## Trabajo pendiente

Hay que terminar de añadir los scripts para cubrir todas las políticas de las categorías "Media" y "Alta" y las calificaciones "Estándar" y "Uso Oficial".

Hecho eso, se pueden plantear alternativas a la ejecución interactiva como la ejecución mediante parámetros.

Una vez se complete eso, se estudiará la posibilidad de crear una aplicación de escritorio que permita un uso más amigable y muestre los resultados de forma más bonita.
