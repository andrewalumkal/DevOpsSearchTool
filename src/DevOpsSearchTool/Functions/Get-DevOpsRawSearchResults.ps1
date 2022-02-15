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
        $DevOpsSearchURI,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DevOpsOrganization
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

                $PathURL = $null
                $PathURL = "https://" + $DevOpsOrganization + ".visualstudio.com/" + $item.project.name + "/_git/" + $item.repository.name + "?path=" + $item.path

                $SearchResults += [PSCustomObject]@{
                    SearchKeyWord = $SearchKeyWord
                    Project       = $item.project.name
                    Repository    = $item.repository.name
                    Path          = $item.path
                    PathURL       = $PathURL
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