### svg-explorer-extension
This repo imported from https://svgextension.codeplex.com/

Installation: From _[Releases](https://github.com/maphew/svg-explorer-extension/releases)_ download and run appropriate binary for your system, then kill `explorer.exe` and icon cache
([ref](https://superuser.com/questions/342052/how-to-get-svg-thumbnails-in-windows-explorer)):
   
    TASKKILL /IM explorer* /F
    DEL "%localappdata%\IconCache.db" /A
    explorer.exe

Original readme follows:

-----
# SVG Viewer Extension for Windows Explorer
Extension module for Windows Explorer to render SVG thumbnails, so that you can have an overview of your SVG files.

## NOTE
New signed installer have been uploaded from version 0.1.1 thanks to www.certum.eu! In this version only the installer is signed, but from now on both the DLLs and the installers will be signed.
Installation
You can just simply use the provided binary installers. Make sure you download the right architecture.

IMPORTANT: The 32 bit installer will run on a 64 bit system, but the extension will not function.

## Build
The easiest way to build it is with the provided Qt project file. I suggest to use Qt Creator. Requirements:

 * Qt SDK
 * Windows 7 SDK
 * Qt SDK 64 bit (for 64 bit builds only) NOTE: You have to compile Qt for 64 bit by yourself.

Thanks to

 * Qt @ http://qt.nokia.com/
 * Jeremy @ urk:http://www.codemonkeycodes.com/2010/01/11/ithumbnailprovider-re-visited/

Last edited Feb 21, 2014 at 12:29 AM by Tibold, version 4

-----
