###############################################################################
# Main_Media_Estandar.ps1
# PERFIL MEDIA ESTANDAR: Categoría = Media, Calificación = Estándar
###############################################################################

# Object with profile metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ProfileInfo = [PSCustomObject]@{
    Name   = 'Media_Estandar'
    Status = 'Pending'
    Groups = @()  # Will contain references to Info objects of each group
}