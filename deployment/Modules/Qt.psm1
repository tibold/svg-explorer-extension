$QtDefaultInstallPath = 'C:\Qt\'
$QtDefaultVersion = '*' # Latest

function Get-InstalledQtSdkVersions {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript( { Test-Path $_ }, ErrorMessage = "Qt install path is not found.")]
        [string] $QtInstallPath = $script:QtDefaultInstallPath
    )

    $installedVersions = Get-ChildItem -Path $QtInstallPath -Directory |`
        Select-Object -ExpandProperty Name |`
        Where-Object { $_.StartsWith('5.') -or $_.StartsWith('4.') } |`
        Sort-Object -Descending

    if (-not $installedVersions) {
        Write-Warning "No Qt Sdk version found in the installation path: $QtInstallPath"
    }
        
    return $installedVersions
}

function Get-QtSdkPath {
    param (
        [Parameter()]
        [string] $QtInstallPath = $script:QtDefaultInstallPath,

        [Parameter()]
        [string] $Version = $script:QtDefaultVersion,

        [Parameter(Mandatory = $true)]
        [string] $Platform
    )
    
    $installedVersions = Get-InstalledQtSdkVersions -QtInstallPath:$QtInstallPath        

    $selectedVersion = @($installedVersions) -match $Version | Select-Object -First 1
    if (-not $selectedVersion) {
        throw "Qt version '$Version' is not installed. Installed versions: $installedVersions"
    }
    $qtPath = Join-Path $QtInstallPath $selectedVersion

    $installedPlatforms = Get-ChildItem -Path $qtPath -Directory `
        | Select-Object -ExpandProperty Name `
        | Sort-Object -Descending
    $selectedPlatform = @($installedPlatforms) -like $Platform | Select-Object -First 1
    if (-not $selectedPlatform) {
        throw "Platform '$Platform' for Qt version '$Version' is not installed. Installed platforms are $installedPlatforms"
    }
    $qtPath = Join-Path $qtPath $selectedPlatform

    return $qtPath
}

function Get-QtMinGWPath {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript( { Test-Path $_ }, ErrorMessage = "Qt install path is not found.")]
        [string] $QtInstallPath = $script:QtDefaultInstallPath,

        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [ValidateSet('32', '64')]
        [string] $Architecture
    )

    $Version = $Version.Replace(".", "")

    $toolsPath = Resolve-Path (Join-Path $QtInstallPath "Tools")

    $mingwPath = Get-ChildItem -Path $toolsPath -Directory -Filter "mingw*_$Architecture" `
        | Where-Object { $_.Name -like "$Version" } `
        | Sort-Object -Descending `
        | Select-Object -First 1
    
    if(-not $mingwPath) {
        throw "Failed to find Qt's MinGW path for version $Version $Architecture bit"
    }

    return $mingwPath
}

function Test-QtSdk {
    [CmdletBinding()]
    param( )

    $qmake = Get-Command 'qmake'
    if (-not $qmake) {
        Write-Warning "Qt qmake is not available on Path"
        return $false
    }

    return $true
}

function Use-QtSdk {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $QtInstallPath = $script:QtDefaultInstallPath,

        [Parameter()]
        [string] $Version = $script:QtDefaultVersion,

        [Parameter(Mandatory = $true)]
        [string] $Platform
    )
    
    $qtPath = Get-QtSdkPath -QtInstallPath:$QtInstallPath -Version:$Version -Platform:$Platform
    $binPath = Join-Path $qtPath 'bin'
    $env:Path = "$binPath;$toolsBinPath;$env:Path"
    Write-Verbose "Using Qt version '$Version' for '$Platform' at '$qtPath'"
}

function Invoke-QMake {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string] $ProjectFile,

        # Parameter help description
        [Parameter()]
        [string] $Configuration,

        # Parameter help description
        [Parameter()]
        [string] $DllDestDir
    )
    
    $arguments = @()
    if ($Configuration) {
        $arguments += '"CONFIG+={0}"' -f $Configuration
    }

    if ($DllDestDir) {
        $arguments += '"DLLDESTDIR+={0}"' -f $DllDestDir
    }

    & qmake @arguments "$ProjectFile" | Write-Verbose
    Assert-LastExitCode -Message "Failed to execute qmake to generate Makefiles"
}

function Invoke-QtWinDeploy {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string] $Binary,

        [Parameter()]
        [string[]] $Enable,

        [Parameter()]
        [string[]] $Disable
    )
    
    $arguments = @()

    if ($Enable) {
        foreach ($item in $Enable) {
            $arguments += "--$item"
        }
    }

    if ($Disable) {
        foreach ($item in $Disable) {
            $arguments += "--no-$item"
        }
    }

    & windeployqt.exe @arguments $Binary | Write-Verbose

    Assert-LastExitCode "Failed to deploy Qt dependencies for the built binary."
} 