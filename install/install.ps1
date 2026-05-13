# ============================================================
#  Blinky Loader Installer - Enhanced Edition
# ============================================================

$Host.UI.RawUI.WindowTitle = "Blinky Loader Installer"

function Write-Color {
    param(
        [string]$Text,
        [ConsoleColor]$Color = 'White',
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Write-Banner {
    Clear-Host
    Write-Color ""
    Write-Color "  ██████╗ ██╗     ██╗███╗   ██╗██╗  ██╗██╗   ██╗" -Color Cyan
    Write-Color "  ██╔══██╗██║     ██║████╗  ██║██║ ██╔╝╚██╗ ██╔╝" -Color Cyan
    Write-Color "  ██████╔╝██║     ██║██╔██╗ ██║█████╔╝  ╚████╔╝ " -Color Cyan
    Write-Color "  ██╔══██╗██║     ██║██║╚██╗██║██╔═██╗   ╚██╔╝  " -Color Cyan
    Write-Color "  ██████╔╝███████╗██║██║ ╚████║██║  ██╗   ██║   " -Color Cyan
    Write-Color "  ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   " -Color Cyan
    Write-Color ""
    Write-Color "  ──────────────────────────────────────────────" -Color DarkGray
    Write-Color "               LOADER INSTALLER v1.1             " -Color DarkCyan
    Write-Color "  ──────────────────────────────────────────────" -Color DarkGray
    Write-Color ""
}

function Write-Step {
    param([string]$Icon, [string]$Message, [ConsoleColor]$Color = 'White')
    Write-Color "  $Icon  $Message" -Color $Color
}

function Write-Divider {
    Write-Color "  ──────────────────────────────────────────────" -Color DarkGray
}

function Show-Spinner {
    param([string]$Message, [int]$Seconds = 2)
    $frames = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $end = (Get-Date).AddSeconds($Seconds)
    $i = 0
    while ((Get-Date) -lt $end) {
        Write-Host "`r  " -NoNewline
        Write-Host $frames[$i % $frames.Length] -ForegroundColor Cyan -NoNewline
        Write-Host "  $Message..." -ForegroundColor DarkGray -NoNewline
        Start-Sleep -Milliseconds 100
        $i++
    }
    Write-Host "`r" -NoNewline
}

# ─── Banner ───────────────────────────────────────────────
Write-Banner

# ─── Credentials ──────────────────────────────────────────
Write-Color "  Please enter your credentials." -Color DarkGray
Write-Color ""
Write-Color "  Email    " -Color DarkCyan -NoNewline
$email = Read-Host

Write-Color "  Password " -Color DarkCyan -NoNewline
$securePassword = Read-Host -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
)

Write-Color ""
Write-Divider

$body = @{
    email             = $email
    password          = $password
    returnSecureToken = $true
} | ConvertTo-Json

try {

    # ─── Auth ─────────────────────────────────────────────
    Write-Color ""
    Show-Spinner -Message "Authenticating" -Seconds 1

    $firebase = Invoke-RestMethod `
        -Method POST `
        -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAvvZg_qWvR2DE-6MbCLn7pLGx2DMTMUkY" `
        -ContentType "application/json" `
        -Body $body

    if (-not $firebase.idToken) {
        Write-Color ""
        Write-Step "✖" "Authentication failed. Check your credentials." -Color Red
        Write-Color ""
        pause; exit 1
    }

    Write-Step "✔" "Authenticated as $email" -Color Green
    Write-Divider

    $token   = $firebase.idToken
    $headers = @{ Authorization = "Bearer $token" }
    $tempExe = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString().Substring(0,5) + ".exe")

    # ─── Download ──────────────────────────────────────────
    Write-Color ""
    Show-Spinner -Message "Downloading loader" -Seconds 2

    Invoke-WebRequest `
        -Uri "https://blinky-backend.onrender.com/download" `
        -Headers $headers `
        -OutFile $tempExe

    if (!(Test-Path $tempExe)) {
        Write-Color ""
        Write-Step "✖" "Download failed. Contact support." -Color Red
        Write-Color ""
        pause; exit 1
    }

    Write-Step "✔" "Loader downloaded successfully." -Color Green
    Write-Divider

    # ─── Launch ────────────────────────────────────────────
    Write-Color ""
    Write-Step "►" "Launching Blinky Loader..." -Color Yellow
    Write-Color ""

    $proc = Start-Process $tempExe -PassThru
    Write-Step "◌" "Waiting for loader to close..." -Color DarkGray
    $proc.WaitForExit()

    Start-Sleep 2
    Remove-Item $tempExe -Force

    # ─── Done ──────────────────────────────────────────────
    Write-Color ""
    Write-Divider
    Write-Color ""
    Write-Step "✔" "Cleanup complete. All done!" -Color Green
    Write-Color ""
    Write-Color "  Exiting..." -Color DarkCyan
    Write-Color ""
    Write-Divider

}
catch {
    Write-Color ""
    Write-Divider
    Write-Step "✖" "An error occurred:" -Color Red
    Write-Color ""
    Write-Color "  $($_.Exception.Message)" -Color DarkRed
    Write-Color ""
    Write-Divider
}

Write-Color ""
pause
