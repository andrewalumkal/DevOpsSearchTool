Function Out-DevOpsSearchResults {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $InputCSVPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $OutputFolderPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DevOpsAccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DevOpsOrganization
    )
  

        
    $DevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

    $OrgURI = "https://almsearch.dev.azure.com/$($DevOpsOrganization)/" 
    $SearchURI = $OrgURI + "_apis/search/codesearchresults?api-version=5.1-preview.1"
 
    
    $ImportedCSV = @(Import-Csv -Path $InputCSVPath -Header "SearchKeyWord")

    $AllResults = @()
    $MissedResults = @()
    

    foreach ($keyword in $ImportedCSV) {
        $CurrentResult = @()
        $CurrentResult = Get-DevOpsRawSearchResults -SearchKeyWord $keyword.SearchKeyWord `
            -DevOpsAuthenicationHeader $DevOpsAuthenicationHeader `
            -DevOpsSearchURI $SearchURI

        if ($CurrentResult.Count -eq 0) {

            $MissedResults += [PSCustomObject]@{
                SearchKeyWord = $keyword.SearchKeyWord
                Project       = "NotFound"
                Repository    = "NotFound"
                Path          = "NotFound"
            }  
            
        }              

        $AllResults += $CurrentResult

    }




    #return $AllResults
    
    ################################
    #EXPORT all data
    ################################

    if ($AllResults.Count -gt 0) {
        $RawExportPath = $OutputFolderPath + "\DevopsSearchResults_KeywordHits_RAW_$(get-date -f yyyyMMdd_HH_mm).csv"
        $GroupedExportPath = $OutputFolderPath + "\DevopsSearchResults_KeywordHits_GroupedSummary_$(get-date -f yyyyMMdd_HH_mm).csv"
        $HighLevelSummaryExportPath = $OutputFolderPath + "\DevopsSearchResults_KeywordHits_TotalCounts_$(get-date -f yyyyMMdd_HH_mm).csv"

        #Output high level summary
        $AllResults | Group-Object -Property SearchKeyWord | Select-Object Count, Name | Export-Csv -Path $HighLevelSummaryExportPath -NoTypeInformation

        #Export RAW data
        $AllResults | Export-Csv -Path $RawExportPath -NoTypeInformation

        
        #Export grouped summary
        $GroupedResults = $AllResults | Group-Object -Property SearchKeyWord, Project, Repository | select Count, Name

        #Format it for CSV
        $GroupedObject = @()
        foreach ($result in $GroupedResults) {
            $ParsedName = @($Result.Name -split "," | foreach { $_.Trim() })
            $GroupedObject += [PSCustomObject]@{
                Count         = $result.Count
                SearchKeyWord = $ParsedName[0]
                Project       = $ParsedName[1]
                Repository    = $ParsedName[2]
            }
        }
        
        $GroupedObject | Export-Csv -Path $GroupedExportPath -NoTypeInformation

    }
    

    if ($MissedResults.Count -gt 0) {
        $MissedResultsPath = $OutputFolderPath + "\DevopsSearchResults_NoResults_$(get-date -f yyyyMMdd_HH_mm).csv"
        $MissedResults | Export-Csv -Path $MissedResultsPath -NoTypeInformation
    }
 
}