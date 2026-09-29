$wallpaperUrl = "https://raw.githubusercontent.com/aashixomen/intune-assets/main/tapeta1.jpg"
$dir = "C:\Temp"
if (!(Test-Path -Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
$localPath = "$dir\wallpaper.jpg"

# Pobranie pliku
Invoke-WebRequest -Uri $wallpaperUrl -OutFile $localPath -UseBasicParsing

# Pancerne ustawienie przez COM interface IActiveDesktop (działa tam, gdzie SystemParametersInfo zawodzi)
$typeDefinition = @"
using System;
using System.Runtime.InteropServices;

public class ActiveDesktop {
    [ComImport, Guid("F490EB00-1240-11D1-9888-006097DEACF9")]
    public class CoClassActiveDesktop {}

    [ComImport, Guid("75048700-EF1F-11D0-9888-006097DEACF9"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IActiveDesktop {
        void SetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string pwszWallpaper, int reserved);
        void GetWallpaper([MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pwszWallpaper, int cchWallpaper, int reserved);
        void GetWallpaperOptions(IntPtr pwOpts, int reserved);
        void SetWallpaperOptions(IntPtr pwOpts, int reserved);
        void SetPattern([MarshalAs(UnmanagedType.LPWStr)] string pwszPattern, int reserved);
        void GetPattern([MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pwszPattern, int cchPattern, int reserved);
        void SetDesktopItemOptions(IntPtr pdiOpts, int reserved);
        void GetDesktopItemOptions(IntPtr pdiOpts, int reserved);
        void AddDesktopItem(IntPtr pdi, int reserved);
        void AddDesktopItemWithUI(IntPtr hwndOwner, IntPtr pdi, int reserved);
        void ModifyDesktopItem(IntPtr pdi, int flags);
        void RemoveDesktopItem(IntPtr pdi, int reserved);
        IntPtr GetDesktopItem(int nID, int reserved);
        IntPtr GetDesktopItemBy(IntPtr pwszItem, int reserved);
        void ReadSettings(int dwReserved);
        void SaveSettings();
        void GetWallpaperOptions(ref WallpaperOptions pwOpts, int reserved);
        void SetWallpaperOptions(ref WallpaperOptions pwOpts, int reserved);
        void ApplyChanges(int dwFlags);
        void GetDesktopItemByID(IntPtr id, int reserved);
        void GetDesktopItemBySource([MarshalAs(UnmanagedType.LPWStr)] string pwszSource, IntPtr pdi, int reserved);
        void SetDesktopItem(IntPtr pdi, int reserved);
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct WallpaperOptions {
        public int dwSize;
        public int dwStyle;
    }

    public static void SetWallpaper(string path) {
        Type t = Type.GetTypeFromCLSID(new Guid("F490EB00-1240-11D1-9888-006097DEACF9"));
        IActiveDesktop ad = (IActiveDesktop)Activator.CreateInstance(t);
        ad.SetWallpaper(path, 0);
        
        WallpaperOptions opt = new WallpaperOptions();
        opt.dwSize = Marshal.SizeOf(typeof(WallpaperOptions));
        opt.dwStyle = 2; // 2 = Stretch/Fill
        ad.SetWallpaperOptions(ref opt, 0);
        
        ad.ApplyChanges(3); // AD_APPLY_ALL | AD_APPLY_FORCE
        Marshal.ReleaseComObject(ad);
    }
}
"@

Add-Type -TypeDefinition $typeDefinition -Language CSharp
[ActiveDesktop]::SetWallpaper($localPath)
