# DevOpsSearchTool

Tool to search multiple keywords across your DevOps repositories and output results


## Example Usage

Import the module.

```powershell
Import-Module .\src\DevOpsSearchTool -Force
```

#### Run search

```powershell
$AzureDevOpsPAT = "*******PersonalAccessTokenFromDevops*******"
$OrganizationName = "MyDevopsOrganization"
$InputCSVPath = "C:\Tools\SearchKeyWords.csv"
$OutputFolderPath = "C:\Tools\SearchResultsFolder"

Out-DevOpsSearchResults -InputCSVPath $InputCSVPath `
                        -OutputFolderPath $OutputFolderPath `
                        -DevOpsAccessToken $AzureDevOpsPAT `
                        -DevOpsOrganization $OrganizationName  
                        
```

The tool will output 4 CSV files

- Summary of total number of hits per keyword
- Count of results by repository 
- Raw results with project / repository / path to file
- If there are keywords with no results, this list will be exported seperately (NoResults)
