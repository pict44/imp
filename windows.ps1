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

# Prevent duplicate code in the profile
$ProfileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -match "Faaah Sound on Failed Command") {
    Write-Host " The sound hook is already installed in your profile. Skipping to prevent duplicates!" -ForegroundColor Yellow
    Write-Host " Installation complete! Please restart PowerShell." -ForegroundColor Green
    exit
}

Write-Host "Adding hook to `$PROFILE..." -ForegroundColor Cyan

# Prepare the code block.
$HookCode = @"

# --- Faaah Sound on Failed Command ---
# Load the modern audio engine
Add-Type -AssemblyName PresentationCore

`$global:OriginalPrompt = `$function:prompt
function prompt {
    `$lastCommandSucceeded = `$?
    `$lastExitCode = `$LASTEXITCODE

    if (-not `$lastCommandSucceeded -or (`$null -ne `$lastExitCode -and `$lastExitCode -ne 0)) {
        # Play the sound using WPF MediaPlayer
        `$global:wmp = New-Object System.Windows.Media.MediaPlayer
        `$global:wmp.Open("$SoundDestFile")
        `$global:wmp.Play()
    }

    `$global:LASTEXITCODE = `$lastExitCode
    & `$global:OriginalPrompt
}
# -------------------------------------
"@

# Append the code to the profile
Add-Content -Path $PROFILE -Value $HookCode

Write-Host " Installation complete! Please restart PowerShell or run: . `$PROFILE" -ForegroundColor Green
