# About PowerShellEnv

This is my collection of profile options and configuration settings for Windows PowerShell.

## Installation Instructions

First, you'll likely need to set your `ExecutionPolicy`... I use `RemoteSigned`. Just run `Set-ExecutionPolicy RemoteSigned`.

To install, either clone this to your `~/Documents/WindowsPowerShell` or run `cmd /c mklink /J "$(Resolve-Path ~\Documents)\WindowsPowerShell" $(Resolve-Path .)` to set up a junction there from your clone directory.

Once that is done, you can run `./install.ps1` to install the modules that are used.

## Need help?

Visit my [website](http://mohundro.com/blog) and shoot me a line.
