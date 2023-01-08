Import-Function Render-ReportField
 
filter IsWorkflow {
    # Look for Command, Action & State workflow
    $workflowIds  = @("{CB01F9FC-C187-46B3-AB0B-97A8468D8303}","{4B7E2DA9-DE43-4C83-88C3-02F042031D04}","{66882E97-C8AA-4E37-8901-7A8AA35ED2ED}","{1C0ACC50-37BE-4742-B43C-96A07A7410A5}")
    if(($workflowIds -contains $_.TemplateID)) { $_; return }
}
 
$database = "master"
 
# Workflow Root
$workflowssRootItem = Get-Item -Path "$($database):{05592656-56D7-4D85-AACF-30919EE494F9}"
$websiteRootItem = Get-Item -Path "$($database):{0DE95AE4-41AB-4D01-9EB0-67441B7C2450}"
$SoutheasternItem = Get-Item -Path "$($database):{D59F23DB-B7CC-4569-AC81-6B682D11C40B}"
 
 
 
$items = $workflowssRootItem.Axes.GetDescendants() | Initialize-Item | IsWorkflow
 
$reportItems = @()
foreach($item in $items) 
{
    $count = 0
    $websitecount = 0;
    $websitepath = @();
    $IsWorkflowsUsedInSoutheastern = $false
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
                    $IsWorkflowsUsedInSoutheastern = $true
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
        "IsWorkflowUsedInSoutheastern" = $IsWorkflowsUsedInSoutheastern
        "InSoutheasternWebsiteUses" = $websitepath.Length
        "ItemPath" = $item.ItemPath
        "ItemID" = $item.ID
        "TemplateName" = $item.TemplateName
    }

    $reportItems += $reportItem   
}
 
$reportProps = @{
    Property = @(
        "Icon",@{Name="Workflow Name"; Expression={$_.Name}},
        @{Name="Website Path"; Expression={$_.WebsitePath}}, 
        @{Name="Total Number of usages"; Expression={$_.UsageCount}},
        @{Name="Number of usages below: "+$websiteRootItem.Name.ToString(); Expression={$_.WebsiteCount}},
        @{Name="Is Workflow Used In Southeastern: "; Expression={$_.IsWorkflowUsedInSoutheastern}},
        @{Name="In Southeastern Website Uses: "; Expression={$_.InSoutheasternWebsiteUses}},
        "ItemID",
        "ItemPath"
        "TemplateName"
    )
    Title = "Custom workflow report"
    InfoTitle = "Available Workflow"
    InfoDescription = "Count of references for each workflow.for" + $websiteRootItem.ItemPath.ToString()

}
 
$reportItems | 
        Sort-Object WebsiteCount -Descending |
        Show-ListView @reportProps
 
Close-Window