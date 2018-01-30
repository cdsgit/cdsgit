![image](https://github.com/cookacounty/cdsgit/blob/master/images/cdsgit-log.png?raw=true)
# Welcome to CdsGit!
Cadence Virtuose Git Integration written in SKILL++

## What is CdsGit?
CdsGit is a SKILL++ library written that allows a user to use
Git to manage their cadence libraries. Unlike other Git clients,
CdsGit is tailored to the cadence DFII infastructure and makes
interfacing with Cadence cells easy.

## Features
* Full integration of common Git commands into Library manager
* Dropdown menus in schematic/layout for version management
* Schematic Diff tool 

## Installation
Cdsgit can be installed with the following steps: 

1) Clone this repository 

2) Add to your .cdsinit
``` lisp
cdsgit_path = "/your/path/to/cdsgit"
setShellEnvVar( strcat("CDSGIT_PATH=" cdsgit_path) )
loadi( strcat(cdsgit_path "/load_cdsgit.il") )
```

3) Add to your cdsLibMgr.il
``` lisp
load(strcat(getShellEnvVar("CDSGIT_PATH") "/menus/cdsLibMgr.menu"))
```

4) Copy in setup/cadence.gitignore to your repository .gitignore to ignore common cadence temporary files (such as lock files).

Example setup files: https://github.com/cdsgit/cdsgit/tree/master/setup

Both the cdsLibMgr.il and .cdsinit can be created in the path where you start Cadence if you do not already have them. There are also copies in the Cadence installation directory if you want to install CdsGit globally.

## Contributing
CdsGit is still a work in progress. The framework for the project is fully laid out and most basic git commands used have been implemented. Very little of the code is documented thanks to SKILL's lack of automated documentation generation. If you are serious about contributing and want more info on the inner workings PM me.

If you have a feature you would like to see or find and issue, please create an issue! Pull Requests are welcome!

## Roadmap
* Schematic Merge tool (IN PROGRESS)
   * Schematic merge tool was working with the exception of wires. Cadence implements wires from a db perspective stupidly and I've given up for a bit on trying to figure that puzzle out.

* Layout Diff + Merge tool (VERY LITTLE PROGRESS)
   * The layout diff is pretty similar to the schematic, there are just a few more object types like vias. I focus very little on layout so there was not much motivation for me to figure out all the things needed to get a true diff. If you know a lot about the layout tool and can write SKILL, your help is welcome!

## Contributers
* Aaron Cook - Senior Design Engineer at Allegro Microsystems. Focus on mixed signal circuit design www.linkedin.com/in/aaron-cook-engineer


