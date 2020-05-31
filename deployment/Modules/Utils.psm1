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

function Use-InnoSetup {
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

function Use-OpenGPG {
    [CmdletBinding()]
    param()

    if(-not (Get-Command 'gpg' -ErrorAction 'SilentlyContinue')) {
        $gitCommand = Get-Command 'git' -ErrorAction 'Stop'
        $usrBinPath = Resolve-Path (Join-Path (Split-Path -Path $gitCommand.Source -Parent) '../usr/bin')

        $env:Path += ";$usrBinPath"
    }
}