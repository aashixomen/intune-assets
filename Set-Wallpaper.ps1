$wallpaperUrl = "https://raw.githubusercontent.com/aashixomen/intune-assets/main/tapeta1.jpg"
$dir = "C:\Temp"
if (!(Test-Path -Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
$localPath = "$dir\wallpaper.jpg"

# Pobranie pliku do C:\Temp
Invoke-WebRequest -Uri $wallpaperUrl -OutFile $localPath

# Użycie interfejsu IActiveDesktop / COM component do natywnego i pewnego ustawienia tapety w Win11
$code = @"
using System;
using System.Runtime.InteropServices;
namespace Win32 {
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
}
"@
Add-Type -TypeDefinition $code

# Wpisanie do rejestru
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $localPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value 2
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value 0

# Odświeżenie pulpitu
[Win32.Wallpaper]::SystemParametersInfo(0x0014, 0, $localPath, 0x01 -bor 0x02)

# Dodatkowe wymuszenie restartu procesu Eksploratora plików, żeby upewnić się, że odświeży widok
Stop-Process -Name explorer -Force
