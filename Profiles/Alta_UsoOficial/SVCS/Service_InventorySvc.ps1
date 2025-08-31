###############################################################################
# Service_InventorySvc.ps1
# Servicio de inventario y compatibilidad de proveedores (InventorySvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_InventorySvc'
  Description   = 'Servicio de inventario y compatibilidad de proveedores (InventorySvc)'
  Type          = 'Service'
  ServiceName   = 'InventorySvc'
  ExpectedValue = 'Manual'
}
