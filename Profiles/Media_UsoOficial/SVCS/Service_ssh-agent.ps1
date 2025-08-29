###############################################################################
# Service_ssh-agent.ps1
# OpenSSH Authentication Agent (ssh-agent)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_ssh-agent'
  Description   = 'OpenSSH Authentication Agent (ssh-agent)'
  Type          = 'Service'
  ServiceName   = 'ssh-agent'
  ExpectedValue = 'Disabled'
}
