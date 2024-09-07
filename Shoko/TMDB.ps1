####################################################################################
### Schedule Auto Search for Missing TMDB Link Series
####################################################################################
$shokoHost = 'site.domain.com' # Set the DNS or the IP of Shoko Server
$headers = @{
    'apikey' = '_YOUR_API_KEY_' # Set the API Key for Shoko Server
}

# Get All Series
$seriesList = (Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Series/?pageSize=0" -Headers $headers -ContentType 'application/json').List

# Get all TMDB Links
$tmbdbList = @()
$apis = @('Movie', 'Show')
foreach ($api in $apis) {
    $tmbdbList += (Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Tmdb/$($api)?restricted=true&pageSize=0" -Headers $headers -ContentType 'application/json').List
}

# Schedule Auto Search for TMDB Missing Links
foreach ($tmdb in $tmbdbList) {
    $linkedSeries = $seriesList | Where-Object { $tmdb.ID -in $_.IDs.TMDB.Movie -or $tmdb.ID -in $_.IDs.TMDB.Show }

    if (!$linkedSeries) {
        "Scheduling Auto Search for: " + $tmdb.Title
        $null = Invoke-RestMethod -Method Post -Uri "https://$shokoHost/api/v3/Series/$($series.IDs.ID)/TMDB/Action/AutoSearch" -Headers $headers -ContentType 'application/json'
    }
}

####################################################################################
#### Enable Auto Match for TMDB and Trackt on All Series
####################################################################################
$shokoHost = 'site.domain.com' # Set the DNS or the IP of Shoko Server
$headers = @{
    'apikey' = '_YOUR_API_KEY_' # Set the API Key for Shoko Server
}

# Get All Series
$seriesList = (Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Series/?pageSize=0" -Headers $headers -ContentType 'application/json').List

foreach ($series in $seriesList) {
    $autoMatchResponse = Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Series/$($series.IDs.ID)/AutoMatchSettings" -Headers $headers -ContentType 'application/json'
    if (!($autoMatchResponse.TMDB -and $autoMatchResponse.Trakt)) {
        "Updating Auto Match for: " + $series.Name
        $autoMatchBody = @{
            "TvDB"  = $true
            "TMDB"  = $true
            "Trakt" = $true
        } | ConvertTo-Json

        $null = Invoke-RestMethod -Method Put -Uri "https://$shokoHost/api/v3/Series/$($series.IDs.ID)/AutoMatchSettings" -Headers $headers -Body $autoMatchBody -ContentType 'application/json'
    }
}

####################################################################################
### Clear Existing TMDB Links and Schedule Auto Search
####################################################################################
$shokoHost = 'site.domain.com' # Set the DNS or the IP of Shoko Server
$headers = @{
    'apikey' = '_YOUR_API_KEY_' # Set the API Key for Shoko Server
}

$endpoints = @('Movie', 'Show')
foreach ($endpoint in $endpoints) {
    $tmbdbList = (Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Tmdb/$($endpoint)?restricted=true&pageSize=0" -Headers $headers -ContentType 'application/json').List

    foreach ($tmdb in $tmbdbList) {
        "Working with: " + $tmdb.Title

        $null = Invoke-RestMethod -Method Delete -Uri "https://$shokoHost/api/v3/Tmdb/$($endpoint)/$($tmdb.ID)?restricted=true&pageSize=0" -Headers $headers -ContentType 'application/json'
        $null = Invoke-RestMethod -Method Post -Uri "https://$shokoHost/api/v3/$($endpoint)/$($tmdb.ID)/TMDB/Action/AutoSearch" -Headers $headers -ContentType 'application/json'
    }
}

####################################################################################
### Set Auto Match for TMDB and Trackt on All Series
####################################################################################
$shokoHost = 'site.domain.com' # Set the DNS or the IP of Shoko Server
$headers = @{
    'apikey' = '_YOUR_API_KEY_' # Set the API Key for Shoko Server
}

# Get All Series
$seriesList = (Invoke-RestMethod -Method Get -Uri "https://$shokoHost/api/v3/Series/?pageSize=0" -Headers $headers -ContentType 'application/json').List

foreach ($series in $seriesList) {
    $null = Invoke-RestMethod -Method Post -Uri "https://$shokoHost/api/v3/Series/$($series.IDs.ID)/TMDB/Action/AutoSearch" -Headers $headers -ContentType 'application/json'
}