Param(
    [string]$BaseUrl = 'http://localhost:5064'
)

function Show-Resp($resp) {
    if ($null -ne $resp) {
        if ($resp -is [System.Net.Http.HttpResponseMessage]) {
            Write-Host "Status: $($resp.StatusCode)"
            $body = $resp.Content.ReadAsStringAsync().Result
            if ($body) { Write-Host $body }
        } else {
            Write-Host ($resp | ConvertTo-Json -Depth 5)
        }
    }
}

Write-Host "Testing API at $BaseUrl"

# 1) GET /games (list)
Write-Host "\n== GET /games"
try {
    $games = Invoke-RestMethod -Uri "$BaseUrl/games" -Method GET -ErrorAction Stop
    $games | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "GET /games failed: $_"
}

# 2) POST /games (create)
Write-Host "\n== POST /games (create sample)"
$create = @{ Name = 'Test Game from Task'; GenreId = 1; Price = 19.99; ReleaseDate = '2025-01-01' }
$body = $create | ConvertTo-Json
try {
    $created = Invoke-RestMethod -Uri "$BaseUrl/games" -Method POST -Body $body -ContentType 'application/json' -ErrorAction Stop
    Write-Host "Created:"; $created | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "POST /games failed: $_"
    exit 1
}

# Preserve created id if available
$createdId = $created.id
if (-not $createdId) { $createdId = $created.Id }
if (-not $createdId) { Write-Host "Could not determine created Id from response."; exit 1 }

# 3) GET /games/{id}
Write-Host "\n== GET /games/$createdId"
try {
    $single = Invoke-RestMethod -Uri "$BaseUrl/games/$createdId" -Method GET -ErrorAction Stop
    $single | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "GET /games/$createdId failed: $_"
}

# 4) PUT /games/{id} (replace)
Write-Host "\n== PUT /games/$createdId (replace)"
$replace = @{ Name = 'Replaced Game from Task'; GenreId = 1; Price = 9.99; ReleaseDate = '2025-01-02' }
try {
    Invoke-RestMethod -Uri "$BaseUrl/games/$createdId" -Method PUT -Body ($replace | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Host "Replaced game $createdId"
} catch {
    Write-Host "PUT /games/$createdId failed: $_"
}

# 5) PATCH /games/{id} (update) - if available
Write-Host "\n== PATCH /games/$createdId (update)"
# Prepare a JSON patch or partial update depending on API; use JSON body with Price only if PATCH is supported
$patch = @{ Price = 4.99 }
try {
    # Try Invoke-RestMethod with METHOD PATCH; PowerShell supports -Method 'Patch'
    Invoke-RestMethod -Uri "$BaseUrl/games/$createdId" -Method Patch -Body ($patch | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Host "Patched game $createdId"
} catch {
    Write-Host "PATCH /games/$createdId failed (maybe not implemented): $_"
}

# 6) DELETE /games/{id}
Write-Host "\n== DELETE /games/$createdId"
try {
    Invoke-RestMethod -Uri "$BaseUrl/games/$createdId" -Method DELETE -ErrorAction Stop
    Write-Host "Deleted game $createdId"
} catch {
    Write-Host "DELETE /games/$createdId failed: $_"
}

# 7) GET /genres
Write-Host "\n== GET /genres"
try {
    $genres = Invoke-RestMethod -Uri "$BaseUrl/genres" -Method GET -ErrorAction Stop
    $genres | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "GET /genres failed: $_"
}

Write-Host "\nTest script finished"
