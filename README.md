# Patrick's Paradots

## Powershell / Software
Everything is managed through the Powershell profile. The full list of software can be found in Profile.ps1 bit it minimally installs:

- git
- VSCode
- Powertoys
- GSudo

These require winget 

### Bootstrap profile
```powershell
iex (irm 'https://raw.githubusercontent.com/PatrickKennedy/dotfiles/trunk/bootstrap.ps1'); Install-Profile
```

### Install software
```powershell
Install-Dependencies
```