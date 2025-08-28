###############################################################################
# Manifest.ps1
# Profile manifest management
###############################################################################

# Function to get the manifest for a given profile.
# - Reads existing manifest if present, otherwise creates a new one.
# - Starts from current disk state (existing groups/policies).
# - Keeps policy order from manifest for existing entries.
# - Appends new policies at the end (alphabetically).
# - Removes groups/policies that no longer exist (silently).
# - Keeps group order from the manifest for existing groups, and appends new
#   groups at the end (alphabetically).
#
# Returns:
#   [PSCustomObject] @{
#     Name   = <ProfileName>
#     Groups = @(
#       @{ Name = <GroupName>; Policies = @(<PolicyBaseName>...) }, ...
#     )
#   }
function Get-ProfileManifest {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  Show-Info -Message "Obteniendo el manifest para el perfil '$ProfileName'..." -NoConsole

  # Build profile and manifest paths relative to this module
  $profilesRootPath = (Resolve-Path -Path (Join-Path $PSScriptRoot "..\Profiles")).Path
  $profilePath = Join-Path $profilesRootPath $ProfileName
  if (-not (Test-Path -LiteralPath $profilePath -PathType Container)) {
    Exit-WithError -Message "No se ha encontrado la carpeta del perfil '$ProfileName' en '$profilesRootPath'."
  }

  $manifestPath = Join-Path $profilePath 'profile.manifest.json'

  # Discover groups on disk (alphabetically)
  $diskGroups = Get-ChildItem -LiteralPath $profilePath -Directory | Sort-Object Name | Select-Object -ExpandProperty Name

  # Read manifest if it exists
  $manifest = $null
  if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    try {
      $raw = Get-Content -LiteralPath $manifestPath -Raw
      $manifest = $raw | ConvertFrom-Json
    }
    catch {
      Exit-WithError -Message "No se ha podido leer el archivo de manifest de '$ProfileName'. $_"
    }
  }

  # Normalize manifest object (order-only schema)
  $manifestName = $ProfileName
  $manifestGroups = @()
  if ($manifest.Groups) {
    $manifestGroups = @($manifest.Groups)
  }

  # Determine final group order:
  # 1) existing groups that are already in manifest (keep manifest order)
  # 2) new groups not in manifest (append alphabetically)
  $manifestGroupNamesExisting = @()
  if ($manifestGroups.Count -gt 0) {
    $manifestGroupNamesExisting = $manifestGroups |
    Where-Object { $_.Name -in $diskGroups } |
    Select-Object -ExpandProperty Name
  }
  $newGroupNames = $diskGroups | Where-Object { $_ -notin $manifestGroupNamesExisting }
  $finalGroupNames = @($manifestGroupNamesExisting + $newGroupNames)

  # Helper: get policy basenames for a given group from disk (alphabetically)
  function Get-DiskGroupPolicies {
    param(
      [Parameter(Mandatory = $true)]
      [string]$GroupName
    )
    $gPath = Join-Path $profilePath $GroupName
    if (-not (Test-Path -LiteralPath $gPath -PathType Container)) { return @() }
    Get-ChildItem -LiteralPath $gPath -File -Filter '*.ps1' |
    Sort-Object Name |
    Select-Object -ExpandProperty BaseName
  }

  # Build final groups with policies (respecting manifest policy order when applicable)
  $finalGroups = @()
  foreach ($gName in $finalGroupNames) {
    $diskPols = Get-DiskGroupPolicies -GroupName $gName

    # Policies listed in manifest for this group (keep order if still exist)
    $mGroup = $manifestGroups | Where-Object { $_.Name -eq $gName } | Select-Object -First 1
    $kept = @()
    if ($mGroup -and $mGroup.Policies) {
      $kept = @($mGroup.Policies | Where-Object { $_ -in $diskPols })
    }

    # Append new policies not present in manifest (alphabetically)
    $added = $diskPols | Where-Object { $_ -notin $kept }
    $finalPolicies = @($kept + $added)

    $finalGroups += [PSCustomObject]@{
      Name     = $gName
      Policies = @($finalPolicies)
    }
  }

  # Create final manifest object (order-only)
  $updatedManifest = [PSCustomObject]@{
    Name   = $manifestName
    Groups = $finalGroups
  }

  # Persist manifest (always write to keep it synced deterministically)
  try {
    $json = $updatedManifest | ConvertTo-Json -Depth 10
    $json | Out-File -LiteralPath $manifestPath -Encoding UTF8
  }
  catch {
    Exit-WithError -Message "No se ha podido guardar el archivo de manifest de '$ProfileName'. $_"
  }

  Show-Info -Message "Manifest sincronizado para el perfil '$ProfileName'." -NoConsole
  return $updatedManifest
}