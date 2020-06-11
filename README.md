# PSModuleCleanup

Small PS module for cleaning up scripts which are unused in your PS module.

## Notes:
It assumes that module's root folder has certain structure:
- all function scripts are placed in folder `${ModuleBase}\Functions`;
- - PUBLIC functions, i.e. functions to export, are placed in subfolder `${Functions}\Public`;
- - PRIVATE functions, i.e. functions which are used in the module but are not exported, are placed in subfolder `${Functions}\Private`;
- ALL functions are PowerShell scripts with extension `'.ps1'`;
- EVERY file contains ONLY ONE function;
- EVERY file has the SAME name that the function it contains.

## How it works:
The module just lists all scripts in given path. Then it reads the content of each script and checks for matches. If any of functions are mentioned in comments - well, the script interpretes it as usage.

## Usage:
```Find-UnusedFunctions -Verbose -Path <Path-to-root-folder> -UsedOrUnused <Used | Unused>```
