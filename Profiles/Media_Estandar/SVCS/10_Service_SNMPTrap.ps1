###############################################################################
# 10_Service_SNMPTrap.ps1
# Captura de SNMP (SNMPTrap)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '10_Service_SNMPTrap'
  Description   = 'Captura de SNMP (SNMPTrap)'
  Type          = 'Service'
  ServiceName   = 'SNMPTrap'
  ExpectedValue = 'Disabled'
}
