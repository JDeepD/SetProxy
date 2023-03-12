# A Proxy Manager for Windows

### Set proxy configs for tools like git, npm with just a single command.

## Installation:

## Pre-requisites: 
### [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3)
### [gsudo](https://github.com/gerardog/gsudo)

#### 1. Manual Installation

Clone the repository
```
git clone https://github.com/JDeepD/SetProxy.git
```

Run `install.ps1`

```
pwsh .\install.ps1
```

To update the tool, pull all the changes and run: 

```
pwsh .\install.ps1 -update
```


## Commands:

#### Create a profile
```
setproxy create
```
#### Show all profiles 
```
setproxy list
```
#### Switch to a profile by nickname 
```
setproxy <nickname>
```
#### Interactive Proxy switching 
```
setproxy
```
#### Unset all proxies
```
setproxy unset
```

## Plus Tip: Use setproxy with [fzf](https://github.com/junegunn/fzf) for an even smoother experience.

##### Put this in your `$PROFILE` (Powershell 7)

```ps1
function fpx{
    $selection=$(setproxy fzflist | fzf --height 40% --pointer=' ' --border --info=inline --prompt='▶ ' --color=fg+:#FFFFFF,bg+:#FF0000,gutter:-1 --exact) -split '\s+' | Select-Object -First 1;
    setproxy $selection
}
```

And run `fpx` to witness sorcery.

### Inspired from [proxyman](https://github.com/himanshub16/ProxyMan) and [nits-proxy](https://github.com/resyfer/nits_proxy)
