<#
.SYNOPSIS
  This script readies a client machine with files and data needed to complete DW workshop
#>
$ErrorActionPreference = "Stop"
$downloadPath = "C:\USGSData3"
$destinationPath = "C:\USGSData4"

# Restore on-premise fireEvents database
# $dbExists = Get-SqlDatabase -Name "fireEvents" -ServerInstance $env:computername -ErrorAction SilentlyContinue
# if (!$dbExists)
# {
#     Write-Output "Restoring SQL database..."
#     $fireEventsDownloadPath = "$destinationPath\fireevents.bak"
#     Invoke-WebRequest "https://sqldwexternaldata.blob.core.windows.net/labmaterials/fireevents.bak" -OutFile $fireEventsDownloadPath
#     Restore-SqlDatabase -ServerInstance $env:computername -Database "fireEvents" -BackupFile $fireEventsDownloadPath
# }
# Write-Output "On-prem database installed"

# Download and unzip ARM template files
$armTemplateDownloadPath = "$downloadPath\loadingtemplates.zip"
Write-Output "Copying ARM template files..."
Invoke-WebRequest "https://sqldwexternaldata.blob.core.windows.net/labmaterials/loadingtemplates.zip" -OutFile $armTemplateDownloadPath
Expand-Archive $armTemplateDownloadPath -DestinationPath $destinationPath -Force
Write-Output "ARM template files copied"

# Download and unzip brute force sql files
$bruteforceSQLDownloadPath = "$downloadPath\bruteforcesql.zip"
Write-Output "Copying BruteforceSQL files..."
Invoke-WebRequest "https://sqldwexternaldata.blob.core.windows.net/labmaterials/BruteForceSQL.zip" -OutFile $bruteforceSQLDownloadPath
Expand-Archive $bruteforceSQLDownloadPath -DestinationPath $destinationPath -Force
Write-Output "BruteforceSQL files copied"

# Download and unzip weatherdata files
$weatherDataDownloadPath = "$downloadPath\weatherData.zip"
Write-Output "Copying Weather data files..."
Invoke-WebRequest "https://sqldwexternaldata.blob.core.windows.net/labmaterials/weatherdata.zip" -OutFile $weatherDataDownloadPath
Expand-Archive $weatherDataDownloadPath -DestinationPath $destinationPath -Force
Write-Output "Weather data files copied"