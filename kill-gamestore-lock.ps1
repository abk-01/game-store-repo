# Find processes referencing GameStore.Api in the command line and kill them
$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'GameStore.Api') }
if ($procs) {
    foreach ($p in $procs) {
        Write-Host "Killing PID: $($p.ProcessId) -> $($p.CommandLine)"
        try { Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop; Write-Host "Killed $($p.ProcessId)" } catch { Write-Host "Failed to kill $($p.ProcessId): $_" }
    }
} else {
    Write-Host "No GameStore.Api processes found by commandline match"
}
# Also attempt to kill processes that have GameStore.Api.exe open by checking dotnet and matching assembly path
$dotnets = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'dotnet') }
foreach ($d in $dotnets) {
    if ($d.CommandLine -match 'GameStore.Api') {
        Write-Host "Also killing dotnet PID: $($d.ProcessId) -> $($d.CommandLine)"
        try { Stop-Process -Id $d.ProcessId -Force -ErrorAction Stop; Write-Host "Killed $($d.ProcessId)" } catch { Write-Host "Failed to kill $($d.ProcessId): $_" }
    }
}
Write-Host 'Done'