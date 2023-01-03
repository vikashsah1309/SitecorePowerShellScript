Write-Host "Search started $(Get-Date -format 'u')"

$startPath = "master:/sitecore/content/Southeastern"
$itemsToProcess = Get-ChildItem $startPath  -Recurse
$itemsToProcess.Count

$list = [System.Collections.ArrayList]@()
if($itemsToProcess -ne $null) {
    $itemsToProcess | ForEach-Object { 
        foreach($field in $_.Fields) {
            if($field.Type -eq "Rich Text") {
                  if($field -match "~/link.aspx") 
                  {
                     $info = [PSCustomObject]@{
						"ID"=$_.ID
						"ItemPath"=$_.ItemPath
						"TemplateName"=$_.TemplateName
						"FieldName"=$field.Name
						"FieldType"=$field.Type
						"FieldValue"=$field
					}
                    [void]$list.Add($info)
                } 
            }
        }
    }
}
  
 
Write-Host "Search ended $(Get-Date -format 'u')"
Write-Host "Items found: $($list.Count)"
$list | Format-Table

$list | Show-ListView 


Close-Window 