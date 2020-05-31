[CmdletBinding()]
Param(
    [Parameter()]
    [string] $ProjectName = 'SVGThumbnailExtension',

    [Parameter()]
    [ValidateSet('release', 'debug')]
    [string] $Configuration = 'release',

    [Parameter()]
    [ValidateSet('x86', 'x64')]
    [string] $Architecture = 'x64',

    [Parameter()]
    [ValidateSet('2015', '2017', '2019')]
    [string] $VSVersion = '2017',

    [Parameter()]
    [ValidateSet('Community', 'Professional', 'Enterprise', 'BuildTools')]
    [string] $VSEdition = 'Community',

    [Parameter()]
    [string] $WinSdk = '10.0.17763.0',
    
    [Parameter()]
    [string] $QtVersion,
    
    [Parameter()]
    [string] $QtInstallPath = 'C:\Qt\',

    # Parameter help description
    [Parameter()]
    [switch] $BuildInstaller = [switch]::Present,
    
    # Parameter help description
    [Parameter()]
    [switch] $SignInstaller,
    
    [Parameter()]
    [string] $InnoSetupPath = 'C:\Program Files (x86)\Inno Setup 6'
)

$ErrorActionPreference = 'stop'

if(-not $QtVersion){
    switch ($VSVersion) {
        '2019' { $QtVersion = '5.15.*' }
        Default { $QtVersion = '5.12.*'}
    }
}

Import-Module (Join-Path $PSScriptRoot 'Modules/Qt.psd1')
Import-Module (Join-Path $PSScriptRoot 'Modules/VisualStudio.psd1')

Write-Verbose "Setting up development environment."

$rootFolder = Resolve-Path (Join-Path  $PSScriptRoot '..')

$distDir = Join-Path $rootFolder "var/dist/$Architecture/$Configuration"
$binary = Join-Path $distDir "SvgSee.dll"
$buildDir = Join-Path $rootFolder "var/build/$Architecture"
$projectFile = Resolve-Path (Join-Path $rootFolder "$ProjectName/$ProjectName.pro")
$licenseDir = Join-Path $rootFolder 'var/licenses'
$installerDir = Join-Path $rootFolder 'var/installer'
$installerPath = Join-Path $installerDir "svg_see_$Architecture.exe"

function Initialize-Environment {

    $vsArchitectureMap = @{
        'x86' = 'x86';
        'x64' = 'amd64';
    }

    Use-VisualStudio `
        -Version $VSVersion `
        -Edition $VSEdition `
        -Architecture $vsArchitectureMap[$Architecture] `
        -Sdk $WinSdk `
        -Spectre `
        -Verbose

    # NOTE: I know it's not right. We'll fix it later.
    $qtArchitectureMap = @{
        'x86' = "msvc$VSVersion";
        'x64' = "msvc${VSVersion}_64";
    }

    $qtParams = @{ }
    if ($QtInstallPath) {
        $qtParams["QtInstallPath"] = $QtInstallPath
    }

    Use-QtSdk `
        -Version $QtVersion `
        -Platform $qtArchitectureMap[$Architecture] `
        @qtParams `
        -Verbose

    if ($BuildInstaller) {
        # Setup "Inno Setup" build environment
        Use-InnoSetup -InstallPath $InnoSetupPath

        if($SignInstaller) {
            Use-OpenGPG
        }
    }
}

function Build-Application {

    Write-Verbose "Building application."

    New-Item -Path $distDir -ItemType Directory -Force
    New-Item -Path $buildDir -ItemType Directory -Force

    Push-Location $buildDir

    try {
        Invoke-QMake -ProjectFile:$projectFile -Configuration:$Configuration -DllDestDir:$distDir
        Invoke-NMake -Command 'clean' -Operation 'clean project'
        Invoke-NMake -Operation 'build project'
    }
    finally {
        Pop-Location
    }
}

function Publish-Application {

    Write-Verbose "Deploying Qt dependencies for the application."

    Invoke-QtWinDeploy -Binary:$binary -Disable translations, quick-import, system-d3d-compiler, angle, opengl-sw

    Write-Verbose "Cleaning up unused Qt plugins."
    $unusedPlugins = @(
        'iconengines',
        'imageformats'
    )
    foreach ($plugin in $unusedPlugins) {
        Remove-Item (Join-Path $distDir $plugin) -Recurse -Force
    }

    Write-Verbose "Gathering licenses"

    New-Item -Path $licenseDir -ItemType Directory -Force
    Copy-Item -Path (Join-Path $QtInstallPath 'Licenses\LICENSE') -Destination (Join-Path $licenseDir "Qt.txt") -Force
}

function Build-Installer {

    Write-Verbose "Building installer"

    Push-Location $rootFolder
    try {
        $issFile = Join-Path $rootFolder "deployment/${ProjectName}.iss";
        iscc "/darch=$Architecture" "$issFile" | Write-Verbose
        Assert-LastExitCode "Failed to build installer"
    }
    finally {
        Pop-Location
    }
}

function Protect-Installer {

    Write-Verbose "Signing installer"

    # Sign the installer
    gpg --detach-sign --armor --yes -o "$installerPath.sig" "$installerPath" | Write-Verbose
    Assert-LastExitCode "Failed to sign installer."

    # Verify the signature
    gpg --verify "$installerPath.sig" "$installerPath" | Write-Verbose
    Assert-LastExitCode "Failed to verify signed installer."

    Write-Verbose "Installer signed successfully"
}

Initialize-Environment
Build-Application
Publish-Application
if ($BuildInstaller) {
    Build-Installer
    if($SignInstaller) {
        Protect-Installer
    }
}
