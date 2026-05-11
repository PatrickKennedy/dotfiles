# Core Profile Module
$BootstrapUrl = 'https://raw.githubusercontent.com/PatrickKennedy/dotfiles/trunk/bootstrap.ps1'

$DependencyIDs = @(
  "Git.Git"
  "Microsoft.WindowsTerminal",
  "Microsoft.VisualStudioCode",
  "GitHub.cli",
  "pnpm.pnpm",
  #"CoreyButler.NVMforWindows",
  "Docker.DockerDesktop",
  "voidtools.Everything",
  "Microsoft.PowerToys",
  "FastStone.Capture",
  "JanDeDobbeleer.OhMyPosh"
)

$DesktopDependencies = @(
  # "CreativeTechnology.SoundBlasterCommand", # Sound Blaster X3
  "CreativeTechnology.CreativeApp", # Used with Katana V2X
  "9NK75KF67S2N" # Tobii Experience (msstore)
)

$GitUnixUtils = 'C:\Program Files\Git\usr\bin'

# gsudo enhanced (disabled due to native sudo)
#Set-Alias 'sudo' 'gsudo'
#Import-Module "gsudoModule"

# Initialize oh-my-posh if it is installed
function Use-Posh {
  if (Get-Command "oh-my-posh" -errorAction SilentlyContinue) {
    if (-not $env:POSH_THEME) {
      $script:defaultTheme = 'Tokyo'
      $env:POSH_THEME = $script:defaultTheme
      [System.Environment]::SetEnvironmentVariable('POSH_THEME', $script:defaultTheme, 'User')
    }

    $script:poshThemePath = "$env:POSH_THEMES_PATH\$($env:POSH_THEME.toLower()).omp.json"
    oh-my-posh init pwsh --config $script:poshThemePath | Invoke-Expression
  }
  else {
    Write-Output "oh-my-posh is not installed. Run 'Install-Dependencies' to install it."
  }
}

function Set-PoshTheme {
  $env:POSH_THEME = $args[0]
  [System.Environment]::SetEnvironmentVariable('POSH_THEME', $env:POSH_THEME, 'User')
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$($env:POSH_THEME.toLower()).omp.json" | Invoke-Expression
}

Use-Posh

<#
.SYNOPSIS
  Adds the unix tools bin folder from git to the PATH environment variable if
  it is not already present.
#>
function Add-UnixUtilsPath {
  if (-not ($env:PATH -split ';' -contains $GitUnixUtils)) {
    [System.Environment]::SetEnvironmentVariable(
      'PATH',
      $GitUnixUtils + ';' + [System.Environment]::GetEnvironmentVariable("Path", "User"),
      [System.EnvironmentVariableTarget]::User)
  }
}

function Install-Dependencies {
  foreach ($id in $DependencyIDs) {
    sudo winget install --id $id
  }

  Add-UnixUtilsPath
  Update-Path

  # Initialize oh-my-posh if it is not already installed
  (Get-Command "Get-PoshThemes" -errorAction SilentlyContinue -ErrorVariable ohMyPoshError)
  if ($ohMyPoshError -ne $null) {
    oh-my-posh init pwsh | Invoke-Expression
  }
}

function Update-Dependencies {
  foreach ($id in $DependencyIDs) {
    Write-Output "Updating $id"
    sudo winget update --id $id
  }

  Update-Path
}

function Update-Profile {
  $script:dynMod = New-Module ([scriptblock]::Create(
    (Invoke-RestMethod $BootstrapUrl))) | Import-Module -PassThru

  Install-Profile -Force

  $dynMod | Remove-Module
}

# Based on https://blog.simontimms.com/2021/06/11/installing-fonts/
function Install-Fonts {
  Write-Output "Installing Fonts"
  # Complete in temp folder to avoid leftovers if something goes wrong
  Push-Location $env:TEMP

  $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts
  Set-Location .\nerd-fonts
  git sparse-checkout init --cone
  git sparse-checkout set patched-fonts/JetBrainsMono/Ligatures
  Write-Output "Installing JetBrains Mono Nerd Font"
  foreach ($font in Get-ChildItem '* Complete Windows Compatible.ttf' -Recurse) {
    Get-Item $font | ForEach-Object { $fonts.CopyHere($_.fullname) }
  }

  Write-Output "Cleaning Up Nerd Fonts"
  Set-Location ..
  Remove-Item .\nerd-fonts\ -Recurse -Force

  Pop-Location
}

function Update-Path {
  $env:Path = (`
      [System.Environment]::GetEnvironmentVariable("Path", "Machine"), `
      [System.Environment]::GetEnvironmentVariable("Path", "User")`
  ) -match '.' -join ';'
}

function Repair-Tobii {
  sudo Restart-Service -DisplayName "tobii*"
}

function Repair-Wsl {
  taskkill /IM "wsl.exe" /F
  sudo Restart-Service LxssManager
}
