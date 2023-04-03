 
filter IsRendering {
    # Look for Controller and View renderings
    $renderingIds = @("{2A3E91A0-7987-44B5-AB34-35C2D9DE83B9}","{99F8905D-4A87-4EB8-9F8B-A9BEBFB3ADD6}")
    if(($renderingIds -contains $_.TemplateID)) { $_; return }
}
 
$database = "master"
 
# Renderings Root
$renderingsRootItem = Get-Item -Path "$($database):{32566F0E-7686-45F1-A12F-D7260BD78BC3}"
$websiteRootItem = Get-Item -Path "$($database):{0DE95AE4-41AB-4D01-9EB0-67441B7C2450}"
$SoutheasternItem = Get-Item -Path "$($database):{D59F23DB-B7CC-4569-AC81-6B682D11C40B}"
  
 
$items = $renderingsRootItem.Axes.GetDescendants() | Initialize-Item | IsRendering
$items.Count 
$reportItems = @()
foreach($item in $items) {
    $count = 0
    $websitecount = 0;
    $websitepath = @();
    $IsRenderingUsedInSoutheastern = $false
    $referrers = Get-ItemReferrer -Item $item
    if ($referrers -ne $null) {
        $count = $referrers.Count
        foreach($ref in $referrers) {
             
            if ($ref.ItemPath.StartsWith($websiteRootItem.ItemPath)) {
                $websitecount++
                if($ref.ItemPath.StartsWith($SoutheasternItem.ItemPath))
                {
                    $websitepath +=$ref.ItemPath;
                    $IsRenderingUsedInSoutheastern = $true
                }
            }
        }
    }
 
    $reportItem = [PSCustomObject]@{
        "Icon" = $item."__Icon"
        "Name"=$item.Name
        "WebsitePath" = $websitepath | select -Unique
        "UsageCount"=$count
        "WebsiteCount" = $websitecount
        "IsRenderingUsedInSoutheastern" = $IsRenderingUsedInSoutheastern
        "InSoutheasternWebsiteUses" = $websitepath.Length
        "ItemPath" = $item.ItemPath
        "ItemID" = $item.ID
    }
    $reportItems += $reportItem
}
 
$reportProps = @{
    Property = @(
        "Icon",@{Name="Rendering Name"; Expression={$_.Name}},
        @{Name="Website Path"; Expression={$_.WebsitePath}}, 
        @{Name="Total Number of usages"; Expression={$_.UsageCount}},
        @{Name="Number of usages below: "+$websiteRootItem.Name.ToString(); Expression={$_.WebsiteCount}},
        @{Name="Is Rendering Used In Southeastern: "; Expression={$_.IsRenderingUsedInSoutheastern}},
        @{Name="In Southeastern Website Uses: "; Expression={$_.InSoutheasternWebsiteUses}},
        "ItemID",
        "ItemPath"
    )
    Title = "Custom rendering report"
    InfoTitle = "Available Renderings"
    InfoDescription = "Count of references for each rendering. Results include only MVC Controller and View renderings.for" + $websiteRootItem.ItemPath.ToString()

}
Write-Host "Search ended $(Get-Date -format 'u')" 
$reportItems | 
        Sort-Object WebsiteCount -Descending |
        Show-ListView @reportProps
 
Close-Window