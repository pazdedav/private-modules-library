<#
.SYNOPSIS
    This script hydrates the documentation for all modules in the repository.
.DESCRIPTION
    This script loops through all the modules in the repository and runs the generate-docs.ps1 script for each module.
    The generate-docs.ps1 script generates the markdown documentation for the module.
    The script requires the registryName and repositoryName as input parameters.
.PARAMETER registryName
    The name of the Azure Container Registry.
.EXAMPLE
    ./scripts/hydrate-docs.ps1 -registryName 'autlibbicepreg'
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$registryName
)

# Get all modules from the modules folder
$modules = Get-ChildItem -Path ./.github/workflows -Filter module-*.yaml

$yamlRootPath = '.github/workflows'

Install-Module -Name powershell-yaml
Import-Module powershell-yaml

# Loop through each module and run the generate-docs.ps1 script
foreach ($module in $modules) {
    Write-Host "Generating documentation for module: $($module.Name)"

    # Parse yaml file to get the value of MODULE_FILE_PATH environment variable
    $fullPath = $yamlRootPath + "/" + $module.Name
    $workflowFile = Get-Content -Path $fullPath -Raw
    $yamlObject = ConvertFrom-Yaml -Yaml $workflowFile

    $moduleFilePath = $yamlObject.env.MODULE_FILE_PATH
    $repositoryName = $yamlObject.env.MODULE_REPO_NAME

    # Run the generate-markdown.ps1 script from the scripts folder
    ./scripts/generate-markdown.ps1 -bicepFilePath $moduleFilePath -registryName $registryName -repositoryName $repositoryName
}

Write-Host "Documentation generation complete."
