
$DependencyIDs = @(
  "gerardog.gsudo",
  "Microsoft.WindowsTerminal",
  "Microsoft.VisualStudioCode",
  "GitHub.cli",
  "Volta.Volta",
  "voidtools.Everything",
  "Microsoft.PowerToys"
)

function Install-Dependencies {
  foreach ($id in $DependencyIDs) {
    winget install --id $id
  }
}

function Update-Dependencies {
  foreach ($id in $DependencyIDs) {
    winget update --id $id
  }
}

function Reload-Path {
  $env:Path=(`
    [System.Environment]::GetEnvironmentVariable("Path","Machine"),`
    [System.Environment]::GetEnvironmentVariable("Path","User")`
  ) -match '.' -join ';'
}
