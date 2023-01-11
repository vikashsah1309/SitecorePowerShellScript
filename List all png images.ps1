$startPath = "master:/sitecore/media library"
$ImagePng= Get-ChildItem $startPath -Recurse | Where-Object {$_["Extension"] -eq "png"} #find the types of media, i.e. (.png, .jpeg,.vtt,etc)
$ImagePng | Show-ListView