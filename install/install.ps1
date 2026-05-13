Write-Host ""
Write-Host "=== Blinky Loader Installer ==="
Write-Host ""

$email = Read-Host "Email"

$securePassword = Read-Host "Password" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
)

$body = @{
    email = $email
    password = $password
    returnSecureToken = $true
} | ConvertTo-Json

try {

    Write-Host ""
    Write-Host "[*] Authenticating..."

    $firebase = Invoke-RestMethod `
        -Method POST `
        -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAvvZg_qWvR2DE-6MbCLn7pLGx2DMTMUkY" `
        -ContentType "application/json" `
        -Body $body

    if (-not $firebase.idToken) {
        Write-Host "[!] Login failed."
        pause
        exit
    }

    Write-Host "[+] Login successful."

    $token = $firebase.idToken

    $headers = @{
        Authorization = "Bearer $token"
    }

    $tempExe = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString().Substring(0,5) + ".exe")

    Write-Host "[*] Downloading loader..."

    Invoke-WebRequest `
        -Uri "https://blinky-backend.onrender.com/download" `
        -Headers $headers `
        -OutFile $tempExe

    if (!(Test-Path $tempExe)) {
        Write-Host "[!] Download failed."
        pause
        exit
    }

    Write-Host "[+] Loader downloaded."
    Write-Host "[*] Launching..."

    $proc = Start-Process $tempExe -PassThru

    Write-Host "[*] Waiting for loader to close..."

    $proc.WaitForExit()

    Start-Sleep 2

    Remove-Item $tempExe -Force

    Write-Host "[+] Cleaned temporary file."

}
catch {

    Write-Host ""
    Write-Host "[!] ERROR:"
    Write-Host $_.Exception.Message
}

pause
