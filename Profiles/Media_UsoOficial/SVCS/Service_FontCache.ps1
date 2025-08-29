###############################################################################
# Service_FontCache.ps1
# Servicio de caché de fuentes de Windows (FontCache)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_FontCache'
  Description   = 'Servicio de caché de fuentes de Windows (FontCache)'
  Type          = 'Service'
  ServiceName   = 'FontCache'
  ExpectedValue = 'Disabled'
}
