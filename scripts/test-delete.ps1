# Lists games and attempts to DELETE the last one, printing status and response body
try {
    $games = Invoke-RestMethod -Uri 'http://localhost:5064/games' -Method GET -ErrorAction Stop
} catch {
    Write-Host "Failed to list games: $_"
    exit 1
}
if (-not $games -or $games.Count -eq 0) {
    Write-Host "No games to delete"
    exit 0
}
$last = $games[-1]
Write-Host "Will attempt to DELETE id=$($last.id) name=$($last.name)"

try {
    $resp = Invoke-WebRequest -Uri "http://localhost:5064/games/$($last.id)" -Method DELETE -UseBasicParsing -ErrorAction Stop
    Write-Host "DELETE succeeded, status: $($resp.StatusCode)"
} catch {
    if ($_.Exception.Response) {
        $r = $_.Exception.Response
        Write-Host "DELETE failed, status: $($r.StatusCode)"
        $sr = New-Object System.IO.StreamReader($r.GetResponseStream())
        Write-Host "Body:"; Write-Host ($sr.ReadToEnd())
    } else {
        Write-Host "Request failed: $_"
    }
}
