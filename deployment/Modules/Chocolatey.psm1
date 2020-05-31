$ChocolateyInstallEnvirnmentVairableKey = "ChocolateyInstall"

function Test-ChocolateyCommand {
    [CmdletBinding()]
    param( )

    $command = Get-Command "choco.exe"
    if(-not $command) {
        Write-Warning "choco is unavailable on the Path."
        return $false
    }

    return $true
}

function Get-ChocolateyInstallPath {
    [CmdletBinding()]
    param( )
    
    return [System.Environment]::GetEnvironmentVariable($script:ChocolateyInstallEnvirnmentVairableKey, [System.EnvironmentVariableTarget]::Machine)
}

function Install-Chocolatey{
    [CmdletBinding()]
    param( )

    Set-ExecutionPolicy Bypass -Scope Process -Force

    $Installer = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
    Invoke-Expression $Installer
}

function Use-Chocolatey {
    [CmdletBinding()]
    param(){
        [Parameter()]
        [switch] $Install
    }
    
    $available = Test-ChocolateyCommand
    if(-not $available)
    {
        $installPath = Get-ChocolateyInstallPath
        if(-not $installPath -and $Install){
            Install-Chocolatey

            $installPath = Get-ChocolateyInstallPath
        }

        if($installPath) {
            $env:PATH = "$installPath\bin;$env:PATH"
            $available = Test-ChocolateyCommand
        }
    }

    if(-not $available){
        throw "Chocolatey is not available. Tried to install: $Install"
    }
}

function Invoke-ChocoInstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Package,

        [Parameter()]
        [string] $Parameters = ""
    )

    &choco install "$Package" --params "$Parameters" | Write-Verbose
}
