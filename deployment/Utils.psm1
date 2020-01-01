function Assert-LastExitCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    if($LASTEXITCODE) {
        throw $Message
    }
}

function Invoke-Batch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Command
    )

    & cmd.exe /c "$Command"
    Assert-LastExitCode "Failed to execute batch command: '$Command'"
}

function Use-VisualStudioBuildTools{
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('2015', '2017', '2019')]
        [string] $Version = '2019',

        [Parameter()]
        [ValidateSet('Community', 'Professional', 'Enterprise', 'BuildTools')]
        [string] $Edition = 'Community',

        [Parameter()]
        [ValidateSet("x86", "amd64", "x86_amd64", "x86_arm", "x86_arm64", "amd64_x86", "amd64_arm", "amd64_arm64")]
        [string] $Architecture = 'amd64',

        [Parameter()]
        [string] $Sdk,

        [Parameter()]
        [switch] $Spectre
    )

    $sdkBasePath = 'C:\Program Files (x86)\Windows Kits\10\bin'
    if(-not (Test-Path (Join-Path $sdkBasePath $Sdk))) {
        throw "Invalid SDK version '$Sdk' was specified"
    }

    $environmentSetupBatchFile = "C:\Program Files (x86)\Microsoft Visual Studio\$Version\$Edition\VC\Auxiliary\Build\vcvarsall.bat"
    if(-not (Test-Path $environmentSetupBatchFile)) {
        throw "Requested Visual Studio version $Version or edition $Edition is not installed"
    }

    $command = """$environmentSetupBatchFile"" $Architecture $Sdk"
    if($Spectre) {
        $command += ' -vcvars_spectre_libs=spectre'
    }
    $command += '  && set'

    $variables = Invoke-Batch -Command:$command

    $variables | .{process{
        if($_ -match '^\[ERROR:.*\]') {
            throw "Failed to configure Visual Studio: $_"
        }
        if ($_ -match '^([^=]+)=(.*)') {
            Set-Item "env:$($matches[1])" $matches[2]
        }
    }}

    Write-Verbose "Using Visual Studio $Architecture build tools from $Version $Edition."
}

function Use-QtBuildTools {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Version = '*', # Use latest

        [Parameter(Mandatory = $true)]
        [string] $Platform,

        [Parameter()]
        [string] $QtInstallPath = 'C:\Qt\'
    )

    if(-not (Test-Path $QtInstallPath)) {
        throw "Qt Install path not found at '$QtInstallPath', please specify the correct install path."
    }

    $installedVersions = Get-ChildItem -Path $QtInstallPath -Directory |`
        Select-Object -ExpandProperty Name |`
        Where-Object { $_.StartsWith('5.')} |`
        Sort-Object -Descending
    $selectedVersion = @($installedVersions) -match $Version | Select-Object -First 1
    if(-not $selectedVersion) {
        throw "Qt version '$Version' is not installed. Installed versions: $installedVersions"
    }
    $qtPath = Join-Path $QtInstallPath $selectedVersion

    $installedPlatforms = Get-ChildItem -Path $qtPath -Directory | Select-Object -ExpandProperty Name

    $qtPath = Join-Path $qtPath $Platform
    if(-not (Test-Path $qtPath)) {
        
        throw "Platform '$Platform' for Qt version '$Version' is not installed. Installed platforms are $installedPlatforms"
    }

    $binPath = Join-Path $qtPath 'bin'
    $env:Path = "$binPath;$toolsBinPath;$env:Path"
    Write-Verbose "Using Qt version '$Version' for '$Platform' at '$qtPath'"
}

function Use-InnoSetup{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $InstallPath = 'C:\Program Files (x86)\Inno Setup 6'
    )

    if(-not (Test-Path $InstallPath)) {
        throw "Inno Setup install path is invalid: $InstallPath"
    }

    $env:Path = "$InstallPath;$env:Path"
}
