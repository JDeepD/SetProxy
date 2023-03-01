$currendir="$PSScriptRoot"
$dirname="setproxy"
$pastedir = Join-Path -Path "$env:LOCALAPPDATA" -ChildPath "$dirname"

echo "Creating Directory: $pastedir" &&
New-Item -Path "$env:LOCALAPPDATA" -Name "$dirname" -ItemType "directory" 1>nul &&

echo "Copying Scripts..." &&
Copy-Item "$currendir/*" -Destination $pastedir &&

echo "Setting Environment Vars..."
$setPath='$env:PATH+=' + "`";$pastedir`""
echo "$setPath" >> $profile
