
new-module -name PatrickDotfileBootstrap -scriptblock {

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
      [Profile]
      $useProfile = $profile,
      # Force the profile to be installed even if it already exists.
      [Alias('F')]
      [switch]
      $Force
    )
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

    iwr "https://raw.githubusercontent.com/PatrickKennedy/dotfiles/trunk/Profile.ps1" -OutFile $useProfile
    & $profile
  }

  set-alias install -value Install-Profile

  export-modulemember -function 'Install-Profile' -alias 'install'
}
