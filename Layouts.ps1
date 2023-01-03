# Find the Layout in Sitecore, which is used in multiple website.
  
filter IsLayout {
    # Look for Layout
    $layoutIds = @("{3A45A723-64EE-4919-9D41-02FD40FD1466}")     #	/sitecore/templates/System/Layout/Layout
    if(($layoutIds -contains $_.TemplateID)) { $_; return }
}
 
$database = "master"
 
# Layout Root
$layoutsRootItem = Get-Item -Path "$($database):{75CC5CE4-8979-4008-9D3C-806477D57619}"       #/sitecore/layout/Layouts
$websiteRootItem = Get-Item -Path "$($database):{0DE95AE4-41AB-4D01-9EB0-67441B7C2450}"       #/sitecore/content
$VikashEnterpriseItem = Get-Item -Path "$($database):{A930CE4D-C15F-4EB6-A97D-668CE249ECA4}"  #/sitecore/content/VikashEnterprise
 
 
$items = $layoutsRootItem.Axes.GetDescendants() | Initialize-Item | IsLayout
 
$reportItems = @()
foreach($item in $items) {
    $count = 0
    $websitecount = 0;
    $websitepath = @();
    $IsLayoutsUsedInVikashEnterprise = $false
    $referrers = Get-ItemReferrer -Item $item
    if ($referrers -ne $null) {
        $count = $referrers.Count
        foreach($ref in $referrers) {
             
            if ($ref.ItemPath.StartsWith($websiteRootItem.ItemPath)) {
            $websitecount++
            if($ref.ItemPath.StartsWith($VikashEnterpriseItem.ItemPath))
            {
                $websitepath +=$ref.ItemPath;
                $IsLayoutsUsedInVikashEnterprise = $true
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
        "IsLayoutsUsedInVikashEnterprise" = $IsLayoutsUsedInVikashEnterprise
        "InVikashEnterpriseWebsiteUses" = $websitepath.Length
        "ItemPath" = $item.ItemPath
        "ItemID" = $item.ID
        "TemplateName" = $item.TemplateName
    }
    $reportItems += $reportItem
    
    
}
 
$reportProps = @{
    Property = @(
        "Icon",@{Name="Layout Name"; Expression={$_.Name}},
        @{Name="Website Path"; Expression={$_.WebsitePath}}, 
        @{Name="Total Number of usages"; Expression={$_.UsageCount}},
        @{Name="Number of usages below: "+$websiteRootItem.Name.ToString(); Expression={$_.WebsiteCount}},
        @{Name="Is Layouts Used In VikashEnterprise: "; Expression={$_.IsLayoutsUsedInVikashEnterprise}},
        @{Name="In VikashEnterprise Website Uses: "; Expression={$_.InVikashEnterpriseWebsiteUses}},
        "ItemID",
        "ItemPath"
    )
    Title = "Custom layout report"
    InfoTitle = "Available Layouts"
    InfoDescription = "Count of references for each layouts.for" + $websiteRootItem.ItemPath.ToString()

}
 
$reportItems | 
        Sort-Object WebsiteCount -Descending |
        Show-ListView @reportProps
 
Close-Window