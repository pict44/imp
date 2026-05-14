# Define variables
$SoundSource = ".\fahhhhh.mp3"
$SoundDestDir = "$env:LOCALAPPDATA\TerminalSound"
$SoundDestFile = "$SoundDestDir\fahhhhh.mp3"

# Check if the MP3 exists in the current folder
if (-not (Test-Path $SoundSource)) {
    Write-Host " Error: fahhhhh.mp3 not found! Please run this script from inside the cloned repository." -ForegroundColor Red
    exit
}

Write-Host "Copying sound file to $SoundDestDir..." -ForegroundColor Cyan
if (-not (Test-Path $SoundDestDir)) {
    New-Item -ItemType Directory -Path $SoundDestDir | Out-Null
}
Copy-Item -Path $SoundSource -Destination $SoundDestFile -Force

# Ensure the PowerShell profile file actually exists
if (-not (Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile..." -ForegroundColor Cyan
    New-Item -Type File -Path $PROFILE -Force | Out-Null
}

Write-Host "Adding hook to `$PROFILE..." -ForegroundColor Cyan

# Prepare the code block. We use backticks (`) to escape the $ signs 
# so they are written literally to the profile instead of executing right now.
$HookCode = @"

# --- Faaah Sound on Failed Command ---
`$global:OriginalPrompt = `$function:prompt
function prompt {
    `$lastCommandSucceeded = `$?
    `$lastExitCode = `$LASTEXITCODE

    if (-not `$lastCommandSucceeded -or (`$null -ne `$lastExitCode -and `$lastExitCode -ne 0)) {
        `$wmp = New-Object -ComObject WMPlayer.OCX
        `$wmp.settings.autoStart = `$true
        `$wmp.URL = "$SoundDestFile"
    }

    `$global:LASTEXITCODE = `$lastExitCode
    & `$global:OriginalPrompt
}
# -------------------------------------
"@

# Append the code to the profile
Add-Content -Path $PROFILE -Value $HookCode

Write-Host " Installation complete! Please restart PowerShell or run: . `$PROFILE" -ForegroundColor Green
