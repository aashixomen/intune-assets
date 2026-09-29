$wallpaperUrl = "https://raw.githubusercontent.com/aashixomen/intune-assets/main/tapeta1.jpg"
$localPath = "$env:USERPROFILE\Pictures\custom_wallpaper.jpg"

# Pobranie pliku
Invoke-WebRequest -Uri $wallpaperUrl -OutFile $localPath

# Ustawienie wpisów w rejestrze dla aktywnego użytkownika
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $localPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value 2 # 2 = Rozciągnij/Wypełnij (Fill), 10 = Dopasuj, 6 = Rozciągnij
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value 0

# Prawdziwe odświeżenie pulpitu za pomocą API Win32 (SPI_SETDESKWALLPAPER)
$code = @"
using System;
using System.Runtime.InteropServices;
public class WallpaperManager {
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
Add-Type -TypeDefinition $code

# SPIF_UPDATEINIFILE (0x01) | SPIF_SENDCHANGE (0x02)
[WallpaperManager]::SystemParametersInfo(0x0014, 0, $localPath, 0x01 -bor 0x02)
