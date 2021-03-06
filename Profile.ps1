
$DependencyIDs = @(
  "Git.Git"
  "Microsoft.WindowsTerminal",
  "Microsoft.VisualStudioCode",
  "GitHub.cli",
  "CoreyButler.NVMforWindows",
  "Docker.DockerDesktop",
  "voidtools.Everything",
  "Microsoft.PowerToys",
  "FastStone.Capture"
)

$DesktopDependencies = @(
  "CreativeTechnology.SoundBlasterCommand",
  "9NK75KF67S2N" # Tobii Experience (msstore)
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
    sudo winget install --id $id
  }

  Add-UnixUtilsPath
  Reload-Path
}

function Update-Dependencies {
  foreach ($id in $DependencyIDs) {
    sudo winget update --id $id
  }

  Reload-Path
}

# Based on https://blog.simontimms.com/2021/06/11/installing-fonts/
function Install-Fonts {
  echo "Installing Fonts"
  # Complete in temp folder to avoid leftovers if something goes wrong
  pushd $env:TEMP

  $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts
  cd .\nerd-fonts
  git sparse-checkout init --cone
  git sparse-checkout set patched-fonts/JetBrainsMono/Ligatures
  echo "Installing JetBrains Mono Nerd Font"
  foreach ($font in gci '* Complete Windows Compatible.ttf' -Recurse) {
    dir $font | %{ $fonts.CopyHere($_.fullname) }
  }

  echo "Cleaning Up Nerd Fonts"
  cd ..
  Remove-Item .\nerd-fonts\ -Recurse -Force

  popd
}

function Reload-Path {
  $env:Path=(`
    [System.Environment]::GetEnvironmentVariable("Path","Machine"),`
    [System.Environment]::GetEnvironmentVariable("Path","User")`
  ) -match '.' -join ';'
}

# gsudo enhanced 
Set-Alias 'sudo' 'gsudo'
Import-Module 'C:\Program Files (x86)\gsudo\gsudoModule.psd1'