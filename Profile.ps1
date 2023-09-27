# Core Profile Module
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
  "FastStone.Capture"
)

$DesktopDependencies = @(
  # "CreativeTechnology.SoundBlasterCommand", # Sound Blaster X3
  "CreativeTechnology.CreativeApp", # Used with Katana V2X
  "9NK75KF67S2N" # Tobii Experience (msstore)
)

$GitUnixUtils = 'C:\Program Files\Git\usr\bin'

# gsudo enhanced
Set-Alias 'sudo' 'gsudo'
Import-Module 'C:\Program Files (x86)\gsudo\gsudoModule.psd1'

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
}

function Update-Dependencies {
  foreach ($id in $DependencyIDs) {
    Write-Output "Updating $id"
    sudo winget update --id $id
  }

  Update-Path
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
