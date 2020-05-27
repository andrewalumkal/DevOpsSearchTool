Function Get-DevOpsRawSearchResults {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SearchKeyWord,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DevOpsAuthenicationHeader,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DevOpsSearchURI
    )
  
    
    try {
        
        $skip = '$skip'
        $top = '$top'

        $Body = @{
            searchText = "$SearchKeyWord"
            $skip      = "0"
            $top       = "1000"
        } | ConvertTo-Json


        $response = Invoke-RestMethod -Uri $DevOpsSearchURI -Method post -Headers $DevOpsAuthenicationHeader -Body $Body -ContentType 'application/json'

        $SearchResults = @()

        foreach ($result in $response) {

            foreach ($item in $result.results) {

                $SearchResults += [PSCustomObject]@{
                    SearchKeyWord = $SearchKeyWord
                    Project       = $item.project.name
                    Repository    = $item.repository.name
                    Path          = $item.path
                }
            }
        }

        return $SearchResults 
    }
    
    catch {
        Write-Error "Error retrieving search results from Azure Devops"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }
 
}