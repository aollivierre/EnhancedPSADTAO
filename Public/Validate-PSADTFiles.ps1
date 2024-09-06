function Validate-PSADTFiles {
    <#
    .SYNOPSIS
    Validates the presence and non-emptiness of required PSADT files and folders.

    .DESCRIPTION
    This function checks if the necessary PSADT files (`Deploy-Application.exe`, `Deploy-Application.exe.config`, `Deploy-Application.ps1`)
    are present in the `Toolkit` folder. It also checks if the `AppDeployToolkit` folder exists and is not empty.

    .PARAMETER ScriptRoot
    The root path of the PowerShell script where the `Toolkit` and `AppDeployToolkit` folders are located.

    .EXAMPLE
    $params = @{
        ScriptRoot = "C:\Path\To\Your\ScriptRoot"
    }
    Validate-PSADTFiles @params
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the root path of the PowerShell script.")]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptRoot
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-PSADTFiles function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Define the required files in the Toolkit folder
        $requiredFiles = @(
            "Deploy-Application.exe",
            "Deploy-Application.exe.config",
            "Deploy-Application.ps1"
        )

        # Define the paths
        $appDeployToolkitPath = Join-Path -Path $ScriptRoot -ChildPath "AppDeployToolkit"
        # $toolkitPath = Join-Path -Path $ScriptRoot -ChildPath "Toolkit"
        $toolkitPath = $ScriptRoot

        # Check if the AppDeployToolkit folder exists and is not empty
        if (-not (Test-Path -Path $appDeployToolkitPath)) {
            throw "AppDeployToolkit folder not found at: $appDeployToolkitPath"
        } elseif ((Get-ChildItem -Path $appDeployToolkitPath | Measure-Object).Count -eq 0) {
            throw "AppDeployToolkit folder is empty: $appDeployToolkitPath"
        } else {
            Write-EnhancedLog -Message "AppDeployToolkit folder exists and is not empty: $appDeployToolkitPath" -Level "INFO"
        }
    }

    Process {
        try {
            # Validate each file's presence and non-emptiness in the Toolkit folder
            $validationPassed = $true

            foreach ($file in $requiredFiles) {
                $filePath = Join-Path -Path $toolkitPath -ChildPath $file
                
                if (-not (Test-Path -Path $filePath)) {
                    Write-EnhancedLog -Message "File missing: $filePath" -Level "ERROR"
                    $validationPassed = $false
                } elseif ((Get-Item $filePath).Length -eq 0) {
                    Write-EnhancedLog -Message "File is empty: $filePath" -Level "ERROR"
                    $validationPassed = $false
                } else {
                    Write-EnhancedLog -Message "File exists and is valid: $filePath" -Level "INFO"
                }
            }

            # Throw an error if validation failed
            if (-not $validationPassed) {
                throw "One or more PSADT files in the Toolkit folder are missing or empty."
            }

        } catch {
            Write-EnhancedLog -Message "An error occurred during file validation: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-PSADTFiles function" -Level "Notice"
    }
}

# Example usage
# $params = @{
#     ScriptRoot = "C:\Path\To\Your\ScriptRoot"
# }
# Validate-PSADTFiles @params
