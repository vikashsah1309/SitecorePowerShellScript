#------------------- First Approch--------------------#
$startPath = "master:/sitecore/media library"
$ImagePng= Get-ChildItem $startPath -Recurse | Where-Object {$_["Extension"] -eq "png"} #find the types of media, i.e. (PNG, JPEG, VTT,etc)
$ImagePng | Show-ListView

#------------------- Second Approch--------------------#

$startPath = "master:/sitecore/media library"
$itemsToProcess = Get-ChildItem $startPath  -Recurse
$itemsToProcess.Count

$list = [System.Collections.ArrayList]@()
if($itemsToProcess -ne $null) {
    $itemsToProcess | ForEach-Object { 
        foreach($field in $_.Fields) {
            if($field.Name -eq "Extension") {  
                  if($_["Extension"] -eq "png")  #find the types of media, i.e. (PNG, JPEG, VTT,etc)
                  {
                     $info = [PSCustomObject]@{
						"ID"=$_.ID
						"ItemPath"=$_.ItemPath
						"TemplateName"=$_.TemplateName
						"FieldValue"=$field
					}
                    [void]$list.Add($info)
                } 
            }
        }
    }
}
$list | Show-ListView 


Close-Window 