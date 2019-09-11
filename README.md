# SVG Viewer Extension for Windows Explorer

Extension module for Windows Explorer to render SVG thumbnails, so that you can have an overview of your SVG files.

## Installation
From _[Releases](https://github.com/maphew/svg-explorer-extension/releases)_ download and run appropriate binary for your system, then kill `explorer.exe` and icon cache
([ref](https://superuser.com/questions/342052/how-to-get-svg-thumbnails-in-windows-explorer)):
   
    TASKKILL /IM explorer* /F
    DEL "%localappdata%\IconCache.db" /A
    explorer.exe
   
You can just simply use the provided binary installers. Make sure you download the right architecture (the 32 bit installer will run on a 64 bit system, but the extension will not function).

## svg-explorer-extension - developer note
This repo was imported from https://svgextension.codeplex.com/

I imported the svg-explorer-extension from CodePlex posted here to GitHub because I use the extension and I didn't want to lose access to it when CodePlex shut down in 2017. 

I'm primarily a python guy and am ill equipped to maintaining this project. So if you know C++ and have some time to spare, please feel free to take over! In the meantime I'm happy to merge pull requests for those who care to offer drive-by fixin's but can't vet them for quality or completeness. ;-)

--Matt

## Build Environment c.2019
Warning: it's many GB. 

- QtCreator -  `choco install qtcreator`
- Qt SDK - _MSVC 2017 64-bit_ using Qt Maintenance Tool installed with QtCreator. Might be problems if install MSVC 32 bit at same time.
- MS Visual Studio - build tools only else many many GB! Reboots necessary, [read the notes](https://chocolatey.org/packages/visualstudio2017buildtools)
  - `choco install visualstudio2017buildtools` 
  - `choco install visualstudio2017-workload-vctools`
- Windows SDK - `choco install windows-sdk-10.-0`

Installation is with [Chocolatey](https://chocolatey.org/) wherever I have a choice. The list may be incomplete. I've installed and uninstalled several different programs and versions of programs trying to find the right combination.

More info: https://github.com/maphew/svg-explorer-extension/issues/18


## Thanks to

 * [Qt](https://www.qt.io/)
 * [Jeremy@urk](https://www.codemonkeycodes.com/2010/01/11/ithumbnailprovider-re-visited/)

## Contributors ✨

Thank you's for helping make this a better project _([emoji key](https://allcontributors.org/docs/en/emoji-key))_:

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
<table>
  <tr>
    <td><a href="http://telcontar.net/"><img align="middle" src="https://avatars3.githubusercontent.com/u/5874930?v=4" width="32px;" alt="Daniel Beardsmore"/> <b>Daniel Beardsmore</b></a><br /><a href="https://github.com/maphew/svg-explorer-extension/commits?author=Daniel-Beardsmore" title="Code">💻</a></td>
    <td> <a href="https://github.com/GitMensch"><img align="middle" src="https://avatars3.githubusercontent.com/u/6699539?v=4" width="32px;" alt="Simon Sobisch"/> <b>Simon Sobisch</b> </a> <a href="https://github.com/maphew/svg-explorer-extension/commits?author=GitMensch" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- ALL-CONTRIBUTORS-LIST:END -->

[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors)  
This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of all kinds welcome (code, docs, user support, ...).