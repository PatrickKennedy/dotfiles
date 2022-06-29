
$DependencyIDs = @(
  "gerardog.gsudo",
  "Git.Git"
  "Microsoft.WindowsTerminal",
  "Microsoft.VisualStudioCode",
  "GitHub.cli",
  "Volta.Volta",
  "Docker.DockerDesktop",
  "voidtools.Everything",
  "Microsoft.PowerToys"
)

$GitUnixUtils = 'C:\Program Files\Git\usr\bin'

<#
.SYNOPSIS
  Adds the unix tools bin folder from git to the PATH environment variable if
  it is not already present.
#>
function Add-UnixUtilsPath {
  if (-not ($env:PATH -split ';' -contains $GitUnixUtils)) {
    [System.Environment]::SetEnvironmentVariable(
      'PATH',
      $GitUnixUtils + ';' + [System.Environment]::GetEnvironmentVariable("Path","User"),
      [System.EnvironmentVariableTarget]::User)
  }
}

function Install-Dependencies {
  foreach ($id in $DependencyIDs) {
    winget install --id $id
  }

  Add-UnixUtilsPath
  Reload-Path
}

function Update-Dependencies {
  foreach ($id in $DependencyIDs) {
    winget update --id $id
  }

  Reload-Path
}

function Reload-Path {
  $env:Path=(`
    [System.Environment]::GetEnvironmentVariable("Path","Machine"),`
    [System.Environment]::GetEnvironmentVariable("Path","User")`
  ) -match '.' -join ';'
}
