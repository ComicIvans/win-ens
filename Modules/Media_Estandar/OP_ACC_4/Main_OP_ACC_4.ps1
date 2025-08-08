###############################################################################
# Main_OP_ACC_4.ps1
# op.acc.4: Proceso de gestión de derechos de acceso
###############################################################################

# Object with group's execution information
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$GroupInfo = [PSCustomObject]@{
    Name     = 'OP_ACC_4'
    Status   = 'Pending'
    Policies = @()  # Here we will store references to the Info objects of each policy
}