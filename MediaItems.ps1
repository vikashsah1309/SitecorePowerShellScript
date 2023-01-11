filter IsMediaLibrary {
    # Look for Media Library PDF, JGEG...
    $mediaIds  = @("{D56DB3AA-7373-4651-837E-8D3977A0B544}","{16692733-9A61-45E6-B0D4-4C0C06F8DD3C}",
    "{777F0C76-D712-46EA-9F40-371ACDA18A1C}","{7BB0411F-50CD-4C21-AD8F-1FCDE7C3AFFE}","{962B53C4-F93B-4DF9-9821-415C867B8903}",
    "{9867C0B9-A7BE-4D96-AD7E-4AD18109ED20}","{F1828A2C-7E5D-4BBD-98CA-320474871548}","{DAF085E8-602E-43A6-8299-038FF171349F}",
    "{E76ADBDF-87D1-4FCB-BA71-274F7DBF5670}","{B60424A5-CE06-4C2E-9F49-A6D732F55D4B}","{0603F166-35B8-469F-8123-E8D87BEDC171}","{4F4A3A3B-239F-4988-98E1-DA3779749CBC}")
    if(($mediaIds -contains $_.TemplateID)) { $_; return }
}
$database = "master"
Write-Host "Search started $(Get-Date -format 'u')"
# Media Library Root
$mediaLibraryRootItem = Get-Item -Path "$($database):{3D6658D8-A0BF-4E75-B3E2-D050FABCF4E1}"
$websiteRootItem = Get-Item -Path "$($database):{0DE95AE4-41AB-4D01-9EB0-67441B7C2450}"
$SoutheasternItem = Get-Item -Path "$($database):{D59F23DB-B7CC-4569-AC81-6B682D11C40B}"
 
 
$items = $mediaLibraryRootItem.Axes.GetDescendants() | Initialize-Item | IsMediaLibrary
$items.Count
$i=0
$reportItems = @()
foreach($item in $items) 
{
    $count = 0
    $websitecount = 0;
    $websitepath = @();
    $IsMediaLibraryUsedInSoutheastern = $false
    $referrers = Get-ItemReferrer -Item $item
    if ($referrers -ne $null) 
    {
        $count = $referrers.Count
        foreach($ref in $referrers) 
        {
            if ($ref.ItemPath.StartsWith($websiteRootItem.ItemPath)) 
            {
                $websitecount++
                if($ref.ItemPath.StartsWith($SoutheasternItem.ItemPath))
                {
                    $websitepath +=$ref.ItemPath;
                    $IsMediaLibraryUsedInSoutheastern = $true
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
        "IsMediaLibraryUsedInSoutheastern" = $IsMediaLibraryUsedInSoutheastern
        "InSoutheasternWebsiteUses" = $websitepath.Length
        "ItemPath" = $item.ItemPath
        "ItemID" = $item.ID
        "TemplateName" = $item.TemplateName
    }

     $reportItems += $reportItem  
     $i++
     $i
}

$reportProps = @{
    Property = @(
        "Icon",@{Name="Media item Name"; Expression={$_.Name}},
        @{Name="Website Path"; Expression={$_.WebsitePath}}, 
        @{Name="Total Number of usages"; Expression={$_.UsageCount}},
        @{Name="Number of usages below: "+$websiteRootItem.Name.ToString(); Expression={$_.WebsiteCount}},
        @{Name="Is Media Library Used In Southeastern: "; Expression={$_.IsMediaLibraryUsedInSoutheastern}},
        @{Name="In Southeastern Website Uses: "; Expression={$_.InSoutheasternWebsiteUses}},
        "ItemID",
        "ItemPath"
        "TemplateName"
    )
    Title = "Custom Media Library report"
    InfoTitle = "Available Media Library"
    InfoDescription = "Count of references for each Media Library. for" + $websiteRootItem.ItemPath.ToString()

}
Write-Host "Search ended $(Get-Date -format 'u')" 
$reportItems | 
        Sort-Object WebsiteCount -Descending |
        Show-ListView @reportProps
 
Close-Window 