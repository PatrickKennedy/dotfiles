new-module -name PatrickDotfileBootstrap -scriptblock {

  function Install-winget {
    <#
    .SYNOPSIS
      Ensures winget is present and if necessary downloading and installing it
    #>
    echo "Checking for Winget..."
    if (-not (Get-Command "winget" -errorAction SilentlyContinue)) {
      echo "Installing Winget"
      Add-AppxPackage "https://aka.ms/getwinget" -errorAction SilentlyContinue
    } else {
      echo "Winget already installed"
    }
  }

  function Install-gsudo {
    winget install "gerardog.gsudo"
  }

  function Install-Profile {
    <#
    .SYNOPSIS
      Downloads and installs the dotfile profile into the current user's profile.
    .EXAMPLE
      iex (irm 'https://raw.githubusercontent.com/PatrickKennedy/dotfiles/trunk/bootstrap.ps1'); Install-Profile
    #>
    param(
      # An optional profile to install the dotfile profile into.
      # Defaults to the current profile
      [String]
      $useProfile = $profile,
      # Force the profile to be installed even if it already exists.
      [Alias('F')]
      [switch]
      $Force
    )
    echo "Bootstrapping Patrick's Paradots"
    echo "--------------------------------"
    echo ""
    # ensure winget is installed before any other operation
    Install-winget
    # ease installation of dependecies
    Install-gsudo

    if (!(Test-Path -Path $useProfile -IsValid)) {
      throw "Profile '$useProfile' is not a valid path."
    }

    if (Test-Path -Path $useProfile) {
      if ($Force) {
        Remove-Item -Path $useProfile -Force
      } else {
        throw "Profile '$useProfile' already exists. Use -Force to overwrite."
      }
    }

    # Ensure containing folder exists
    $profileDirectory = $(Split-Path $useProfile)
    if (-not (Test-Path -Path $profileDirectory)) {
      New-Item -Type Directory -Path $profileDirectory
    }

    iwr "https://raw.githubusercontent.com/PatrickKennedy/dotfiles/trunk/Profile.ps1" -OutFile $useProfile
    . $useProfile
  }

  set-alias install -value Install-Profile

  export-modulemember -function 'Install-Profile' -alias 'install'
}
