[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$response = Invoke-WebRequest "https://blinkymc.xyz/install/install.ps1"
$script = [System.Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray())

iex $script
