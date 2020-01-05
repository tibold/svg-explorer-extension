$VisualStudioVersions = @('2015', '2017', '2019') 
$VisualStudioEditions = @('Community', 'Professional', 'Enterprise', 'BuildTools')

class ValidVisualStudioVersions : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
	  return $script:VisualStudioVersions
    }
}

class ValidVisualStudioEditions : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
	  return $script:VisualStudioEditions
    }
}

function Assert-WindowsSdk {
    [CmdletBinding()]
    param(        
        [Parameter()]
        [string] $Sdk
    )
    
    $sdkBasePath = 'C:\Program Files (x86)\Windows Kits\10\bin'
    if(-not (Test-Path (Join-Path $sdkBasePath $Sdk))) {
        throw "Invalid SDK version '$Sdk' was specified"
    }
}

function Get-VisualStudioVCVarsAll {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet([ValidVisualStudioVersions])]
        [string] $Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet([ValidVisualStudioEditions])]
        [string] $Edition
    )

    $environmentSetupBatchFile = "C:\Program Files (x86)\Microsoft Visual Studio\$Version\$Edition\VC\Auxiliary\Build\vcvarsall.bat"
    return $environmentSetupBatchFile
}

function Test-VisualStudio {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet([ValidVisualStudioVersions])]
        [string] $Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet([ValidVisualStudioEditions])]
        [string] $Edition
    )
    
    $environmentSetupBatchFile = Get-VisualStudioVCVarsAll -Version:$Version -Edition:$Edition
    return (Test-Path $environmentSetupBatchFile)
}

function Use-VisualStudio{
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet([ValidVisualStudioVersions])]
        [string] $Version = '2019',

        [Parameter()]
        [ValidateSet([ValidVisualStudioEditions])]
        [string] $Edition = 'Community',

        [Parameter()]
        [ValidateSet("x86", "amd64", "x86_amd64", "x86_arm", "x86_arm64", "amd64_x86", "amd64_arm", "amd64_arm64")]
        [string] $Architecture = 'amd64',

        [Parameter()]
        [string] $Sdk,

        [Parameter()]
        [switch] $Spectre
    )

    Assert-WindowsSdk -Sdk:$Sdk
    $available = Test-VisualStudio -Version:$Version -Edition:$Edition
    if(-not $available) {
        throw "Requested Visual Studio version $Version or edition $Edition is not installed"
    }

    $environmentSetupBatchFile = Get-VisualStudioVCVarsAll -Version:$Version -Edition:$Edition
    $command = """$environmentSetupBatchFile"" $Architecture $Sdk"
    if($Spectre) {
        $command += ' -vcvars_spectre_libs=spectre'
    }
    $command += '  && set'

    # Invoke vcvarsall.bat and dump all environment variables
    $variables = Invoke-Batch -Command:$command
    $variables | .{process{
        if($_ -match '^\[ERROR:.*\]') {
            # Throw when vcvarsall.bat reported an error.
            throw "Failed to configure Visual Studio: $_"
        }
        if ($_ -match '^([^=]+)=(.*)') {
            # Set the dumped environment variables for the current environment
            Set-Item "env:$($matches[1])" $matches[2]
        }
    }}

    Write-Verbose "Using Visual Studio $Architecture build tools from $Version $Edition."
}

function Invoke-NMake {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Command,

        [Parameter(Mandatory = $true)]
        [string] $Operation
    )

    & nmake $Command | Write-Verbose
    Assert-LastExitCode -Message "Invoking nmake returned '$LASTEXITCODE' for operation: $Operation"
}
