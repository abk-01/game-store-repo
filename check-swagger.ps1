$uri = 'http://localhost:5064/'
Write-Host "Checking $uri"
try {
    $r = Invoke-WebRequest -Uri $uri -MaximumRedirection 0 -ErrorAction Stop
    Write-Host "Status: $($r.StatusCode)"
    if ($r.Headers['Location']) { Write-Host "Location: $($r.Headers['Location'])" }
} catch {
    $err = $_.Exception
    if ($err.Response) {
        Write-Host "Status: $($err.Response.StatusCode.Value__)"
        if ($err.Response.Headers['Location']) { Write-Host "Location: $($err.Response.Headers['Location'])" }
    } else {
        Write-Host "Request failed: $($err.Message)"
    }
}

# Fetch Swagger page
$swaggerUri = 'http://localhost:5064/swagger/index.html'
Write-Host "\nFetching $swaggerUri"
try {
    $s = Invoke-WebRequest -Uri $swaggerUri -UseBasicParsing -ErrorAction Stop
    $len = $s.Content.Length
    Write-Host "Swagger content length: $len"
    $snippet = $s.Content.Substring(0, [math]::Min(600, $len))
    Write-Host "--- Swagger HTML snippet (first 600 chars) ---"
    Write-Host $snippet
} catch {
    Write-Host "Could not fetch swagger page: $($_.Exception.Message)"
}
