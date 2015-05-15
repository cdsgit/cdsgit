# Welcome to CdsGit!
Cadence Virtuose Git Integration written in SKILL++

## What is CdsGit?
CdsGit is a library written in SKILL++ that allows a user to use
Git to manage their cadence libraries without the burden of
a Git client that is not designed specifically for the way Cadence
manages it's files.

## Features
* Full integration of common Git commands into Library manager
* Dropdown menus in schematic/layout for version management
* Schematic/Layout Diff tool (IN PROGRESS)
* Schematic/Layout Merge tool (IN PROGRESS)

## Installation
Installation is simple! Clone this repository and add to your .cdsinit
```skill
loadi('/your/path/to/cdsgit/load_cdsgit.il')
```

## Development
CdsGit is a work in progress. The framework for the project is fully laid
but there are many features that are still in progress such as the diff
and merging capabilities. There are also a few bugs kicking around
that will be fixed in the near future.
