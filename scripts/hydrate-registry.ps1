<#
.SYNOPSIS
    This script hydrates the Private Modules Registry (ACR).
.DESCRIPTION
    This script loops through all modules in the repository and adds an extra line to bicep templates.
.PARAMETER moduleType
    The type of modules to publish to the Azure Container Registry. Valid values are 'res', 'ptn', and 'avdbaseline'.
.EXAMPLE
    ./scripts/hydrate-registry.ps1 -moduleType 'res'
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('res', 'ptn', 'avdbaseline')]
    [string]$moduleType = 'res'
)

# Variables

# Set the filter based on the module type
switch ($moduleType) {
    'res' {
        $filter = "module-res-*.yaml"
        $excluded = ""
    }
    'ptn' {
        $filter = "module-ptn-*.yaml"
        $excluded = "module-ptn-avd-baseline-*.yaml"
    }
    'avdbaseline' {
        $filter = "module-ptn-avd-baseline-*.yaml"
        $excluded = ""
    }
}

$yamlRootPath = '.github/workflows'

# Get all modules from the modules folder
$modules = Get-ChildItem -Path ./.github/workflows/* -Include $filter -Exclude $excluded

Write-Output "Found $($modules.Count) modules of type $($moduleType) to hydrate."

Install-Module -Name powershell-yaml
Import-Module powershell-yaml

# Loop through each module and add an extra line to the bicep templates
foreach ($module in $modules) {
    Write-Host "Touching the module: $($module.Name)"

    # Parse yaml file to get the value of MODULE_FILE_PATH environment variable
    $fullPath = $yamlRootPath + "/" + $module.Name
    $workflowFile = Get-Content -Path $fullPath -Raw
    $yamlObject = ConvertFrom-Yaml -Yaml $workflowFile

    $moduleFilePath = $yamlObject.env.MODULE_FILE_PATH

    # Add an extra line to the bicep templates
    $moduleContent = Get-Content -Path $moduleFilePath
    $moduleContent += "`n// Published to the Azure Container Registry"
    Set-Content -Path $moduleFilePath -Value $moduleContent

    Write-Host "Touched the module: $($module.Name)"
}

Write-Host "Registry hydration for module type $($moduleType) completed."
