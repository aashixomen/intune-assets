$wallpaperUrl = "https://raw.githubusercontent.com/aashixomen/intune-assets/main/tapeta1.jpg"
$localPath = "$env:USERPROFILE\Pictures\custom_wallpaper.png"

# 1. Pobranie pliku do folderu Obrazy użytkownika
Invoke-WebRequest -Uri $wallpaperUrl -OutFile $localPath

# 2. Bezpośrednie i natywne wymuszenie tapety w API Windowsa (SystemParametersInfo)
$code = @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
Add-Type -TypeDefinition $code
[Wallpaper]::SystemParametersInfo(0x0014, 0, $localPath, 0x01 -bor 0x02)
