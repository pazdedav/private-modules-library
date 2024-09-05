<#
.SYNOPSIS
    A heler script to create a new private module in the modules folder.
.DESCRIPTION
    The script creates a new private module in the modules folder. The script copies all files from the _template folder to the new module folder and replaces the placeholder strings with the new module name.
.NOTES
    This script requires PowerShell 7.0 or later.
.EXAMPLE
    ./scripts/New-PrivateModule.ps1 -ModuleName 'my-new-module' -ModuleType 'ptn'
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z0-9._/-]{1,20}$')]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [ValidateSet('ptn', 'res')]
    [string]$ModuleType
)

# Set the progress preference to silently continue
# in order to avoid progress bars in the output
# as this makes web requests very slow
# Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ProgressPreference = 'SilentlyContinue'

$NewModuleFolder = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "modules\$ModuleType\$ModuleName"
$TemplateFolder = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "modules\_template"

# Check if $NewModuleFolder exist and if not, creates that folder.
Write-Output "Creating the new module folder..."
if (-not (Test-Path -Path $NewModuleFolder)) {
    try {
        New-Item -Path $NewModuleFolder -ItemType Directory -ErrorAction Stop
    }
    catch {
        $ErrorMessage = $_.Exception.message
        Write-Error "Error creating the new module folder - $ErrorMessage"
    }
}

# Copy all files from the template folder to the new module folder
Write-Output "Copying files from the template folder to the new module folder..."
try {
    Copy-Item -Path "$TemplateFolder/*" -Destination $NewModuleFolder -Recurse -Force -ErrorAction Stop
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Error "Error copying files from the template folder to the new module folder - $ErrorMessage"
}

# Edit the workflow definition template file in the new module folder and replace the PLACEHOLDER string with the new module name
Write-Output "Editing the workflow definition file..."
try {
    $PublishModuleTemplate = Join-Path -Path $NewModuleFolder -ChildPath "module-type-placeholder-publish.yaml"
    (Get-Content -Path $PublishModuleTemplate) | ForEach-Object { $_ -replace 'PLACEHOLDER_MODULE_NAME', $ModuleName } | Set-Content -Path $PublishModuleTemplate
    (Get-Content -Path $PublishModuleTemplate) | ForEach-Object { $_ -replace 'PLACEHOLDER_MODULE_TYPE', $ModuleType } | Set-Content -Path $PublishModuleTemplate

    # Rename the file to deploy-$ModuleType-$ModuleName.yaml
    Rename-Item -Path $PublishModuleTemplate -NewName "module-$ModuleType-$ModuleName.yaml" -ErrorAction Stop

    # Move the file to the workflows folder
    $WorkflowsFolder = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath ".github/workflows"
    Move-Item -Path $NewModuleFolder\module-$ModuleType-$ModuleName.yaml -Destination $WorkflowsFolder -Force -ErrorAction Stop

}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Error "Error editing the workflow definition yaml file - $ErrorMessage"
}





