# Find the Items in Sitecore, where has "Rich Text" field and has link with other items.

Write-Host "Search started $(Get-Date -format 'u')"

$startPath = "master:/sitecore/content/VikashEnterprise"
$itemsToProcess = Get-ChildItem $startPath  -Recurse
$itemsToProcess.Count

$list = [System.Collections.ArrayList]@()
if($itemsToProcess -ne $null) {
    $itemsToProcess | ForEach-Object { 
        foreach($field in $_.Fields) {
            if($field.Type -eq "Rich Text") {   #Check filed type is "Rich Text" or not
                  if($field -match "~/link.aspx")  #Check Rich Text field is used in datasource or not. 
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