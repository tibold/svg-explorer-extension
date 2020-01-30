# SVG Viewer Extension for Windows Explorer

Extension module for Windows Explorer to render SVG thumbnails, so that you can have an overview of your SVG files.

## Installation
From _[Releases](https://github.com/tibold/svg-explorer-extension/releases)_ download and run appropriate binary for your system. Note: you probably need an _unsigned_ version as the signed binary certificate was revoked (#29) around Dec 2019.

Then kill `explorer.exe` and icon cache
([ref](https://superuser.com/questions/342052/how-to-get-svg-thumbnails-in-windows-explorer)):
   
    TASKKILL /IM explorer* /F
    DEL "%localappdata%\IconCache.db" /A
    explorer.exe
   
Make sure you download the right architecture (the 32 bit installer will run on a 64 bit system, but the extension will not function).

### Automatic builds
Development install exe's are created from every commit through the continual-integration system and can be fetched from:

https://ci.appveyor.com/project/tibold/svg-explorer-extension/build/artifacts

Being dev releases, they might not work. Current status: [![Build status Appveyor](https://ci.appveyor.com/api/projects/status/github/tibold/svg-explorer-extension?svg=true)](https://ci.appveyor.com/project/tibold/svg-explorer-extension)  

## Developer Build Environment c.2019
Warning: it's about 10 GB. 

- QtCreator
- Qt SDK - _MSVC 2017 64-bit_ using Qt Maintenance Tool installed with QtCreator. Might be problems if install MSVC 32 bit at same time. (Qt Creator & SDK: 7.2 GB)
- MS Visual Studio - build tools only else many more GB. Reboots necessary, [read the notes](https://chocolatey.org/packages/visualstudio2017buildtools) (2.5 GB)
- Windows SDK
- Inno Setup v6

[Chocolatey](https://chocolatey.org/) installation:

    choco install qtcreator, windows-sdk-10.-0, innosetup
    choco install visualstudio2017buildtools
    choco install visualstudio2017-workload-vctools ^
      --params "--add Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre"

**Quick start** after developer env is set:

    git clone https://github.com/tibold/svg-explorer-extension.git
    cd svg-explorer-extension\deployment
    .\build.cmd

## History
Tibold Kandrai started the project in 2012, first on Google Code, Codeplex. Life happened and Tibold didn't have time to work on it any more, though the extension continued to work more than it didn't so people kept using it. 

In 2017 Codeplex shut down and turned into a read-only warehouse. Matt Wilkie imported the project to GitHub and continued to maintain the project as best as a python-not-c++ guy could. The extension continued to work more than not, though the problems started to add up as Windows continued to evolve and change underfoot.

In late 2019 a lucky confluence of stubborn brute force learning on Matt's part and newly active and knowledgeable contributors (Daniel, Simon, Voodoo) revived the feared soon-to-be-comatose project. Bugs were fixed and automatic binary builds came into being. Life rebounded. Right on the heels of this, Tibold regained attention time for side-projects and again assumed the project owner mantle.

On 1st of January, 2020 version v1.0.0 was released including all bug fixes and up to date dependencies. Let's see where the rest of the year takes us. :-)

## Contributors ✨

Thank you's for helping make this a better project _([emoji key](https://allcontributors.org/docs/en/emoji-key))_:

* [Qt](https://www.qt.io/) - dev platform and libraries
* [Jeremy@urk](https://www.codemonkeycodes.com/2010/01/11/ithumbnailprovider-re-visited/) - initial example
* [Tibold Kandrai](https://github.com/tibold) - Project creator and primary developer

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://telcontar.net/"><img src="https://avatars3.githubusercontent.com/u/5874930?v=4" width="32px;" alt=""/><br /><sub><b>Daniel Beardsmore</b></sub></a><br /><a href="https://github.com/tibold/svg-explorer-extension/commits?author=Daniel-Beardsmore" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/GitMensch"><img src="https://avatars3.githubusercontent.com/u/6699539?v=4" width="32px;" alt=""/><br /><sub><b>Simon Sobisch</b></sub></a><br /><a href="https://github.com/tibold/svg-explorer-extension/commits?author=GitMensch" title="Documentation">📖</a> <a href="https://github.com/tibold/svg-explorer-extension/commits?author=GitMensch" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/voodoo66"><img src="https://avatars1.githubusercontent.com/u/14852960?s=400&v=4" width="32px;" alt=""/><br /><sub><b></b></sub></a><br /><a href="https://github.com/tibold/svg-explorer-extension/commits?author=voodoo66" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/tibold"><img src="https://avatars2.githubusercontent.com/u/1974659?v=4" width="32px;" alt=""/><br /><sub><b>Tibold Kandrai</b></sub></a><br /><a href="https://github.com/tibold/svg-explorer-extension/commits?author=tibold" title="Tests">⚠️</a> <a href="#ideas-tibold" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/tibold/svg-explorer-extension/commits?author=tibold" title="Code">💻</a> <a href="#maintenance-tibold" title="Maintenance">🚧</a> <a href="https://github.com/tibold/svg-explorer-extension/commits?author=tibold" title="Documentation">📖</a></td>
    <td align="center"><a href="http://www.maphew.com"><img src="https://avatars3.githubusercontent.com/u/486200?v=4" width="32px;" alt=""/><br /><sub><b>Matt Wilkie</b></sub></a><br /><a href="#maintenance-maphew" title="Maintenance">🚧</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors)  
This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of all kinds welcome (code, docs, user support, ...).
