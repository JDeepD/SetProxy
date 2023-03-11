$unset = New-Object System.Management.Automation.Host.ChoiceDescription '&Unset', ''
[System.Management.Automation.Host.ChoiceDescription[]]$options = ($unset)
$proxyserverspath = "$PSScriptRoot\proxyservers.json"
if (!(Test-Path $proxyserverspath)){
	Write-Output "$proxyserverspath not found..."
	Write-Output "Creating $proxyserverspath"
	New-Item $proxyserverspath -Force
}
$JsonProfiles = Get-Content -Raw $proxyserverspath | ConvertFrom-Json
$argv=$args[0]
$nicks = @{};

# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyOverride -Value "localhost;127.*;10.*"
# Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyServer' -Value 'proxy_address:port'

function setproxy($proxyserver){
	Write-Output 'Setting Proxy to' $proxyserver;
	Write-Output 'Setting git proxy...';
	git config --global http.proxy $proxyserver;
	git config --global https.proxy $proxyserver;
	Write-Output 'Done...';
	Write-Output 'Setting npm proxy...';
	npm config set -g proxy $proxyserver;
	Write-Output 'Done...';
	Write-Output 'Setting Windows Proxy...';
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyServer' -Value $proxyserver;
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyEnable' -Value 1;
	Write-Output 'Done...';
}

function unsetproxy{
	Write-Output 'Unsetting git proxy vars...';
	git config --global --unset http.proxy;
	git config --global --unset https.proxy;
	Write-Output 'Done...';
	Write-Output 'Unsetting npm proxy vars...'
	npm config rm -g proxy;
	Write-Output 'Done...';
	Write-Output 'Unsetting Windows Proxy...';
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyEnable' -Value 0;
	Write-Output 'Done...';
}

function create{
	$name = Read-Host "Enter a Name for Profile"
	if ($name -in ("create", "list", "unset")){
		Write-Output "Cannot use reserved keywords for profile names"
		exit;
	}
	$nickname = Read-Host "Enter a nickname for Profile"
	$proxyserver = Read-Host "Enter proxyserver"
	$proxyport = Read-Host "Enter proxyport"
	if($JsonProfiles.profiles -eq $null){
		$JsonProfiles += @{"profiles" = @()}
	}
	$JsonProfiles.profiles += @(@{
		"name" = "&" + $name
		"nickname" = $nickname
		"proxyserver" = $proxyserver
		"proxyport" = $proxyport
	})
	$JsonProfiles | ConvertTo-Json | Set-Content $proxyserverspath
	Write-Output "Profile saved in $proxyserverspath"
}

function setproxyinteractive{
	$title = 'Select Proxy Server: '
	$message = 'Configure Proxies for: npm, git, windows'
	$result = $host.ui.PromptForChoice($title, $message, $options, 0)
	if($result -eq 0){
		unsetproxy;
	} 
	elseif($result -in 1..$options.count){
		setproxy($options[$result].HelpMessage)
	}
}

forEach($profile  in $JsonProfiles.profiles){
	$nicks += @{$profile.nickname = ($profile.proxyserver + ":" + $profile.proxyport)}
}

if($JsonProfiles.profiles.count -eq 0){
	Write-Output "No Configs Available in $proxyserverspath"
	$confirm = Read-Host "Do you want to create a new profile?[y/n]?"
	if($confirm -eq "y"){
		create
		exit
	}
	exit
}
elseif($argv -eq "unset"){
	unsetproxy;
	exit;
}
elseif($argv -in $nicks.Keys){
	setproxy($nicks[$argv])
	exit;
}
elseif($argv -eq "list"){
	forEach($profile in $JsonProfiles.profiles){
		Write-Output $profile
	}
	exit;
}
elseif($argv -eq "create"){
	create;
	exit;
}
else{
	Write-Output "No proxy server found. Choose from below: ";
	forEach($profile in $JsonProfiles.profiles){
		$options += New-Object System.Management.Automation.Host.ChoiceDescription $profile.name, ($profile.proxyserver + ":" + $profile.proxyport)
}
	setproxyinteractive;
	exit;
}
