# Package

version       = "0.1.0"
author        = "litlighilit"
description   = "A tool to distribute different code source to relative compiler/interpreter"
license       = "MIT"
srcDir        = "src"
bin           = @["A"]
binDir        = "bin"

#installFiles  = @["A.nim","pathconsts.nim"]
# Dependencies

requires "nim >= 1.6.6"

import std/os
from std/os import `/`

#from std/strutils import strip, splitlines

#[ even this doesn't work
import std/macros
macro switchIncl: typed =
  if fileExists"./pathconsts.nim":
    parseStmt "import ./pathconsts"
  else:
    parseStmt "import ./src/pathconsts"
switchIncl()
]#
const # so I had to copy from pathconsts.nim
  CnfFn = "arun.cnf"
  CnfDir{.strdefine.} = getConfigDir()
  CnfPath* = CnfDir/CnfFn
  AltCnfDir*{.strdefine.} = "."
  Temp* = getTempDir()&".aruncache"

# init config

const # here use non-capital to distingish from those of pathconsts
  cnfDir = "src" # ? usage of `srcDir` results in `Error: cannot evaluate at compile time: srcDir`
  cnfPath = cnfDir/CnfFn 
task cfg, "echo cfg info":
  echo "[", cnfPath,"]:"
  echo readFile cnfPath

# hooks

before install:
  if fileExists CnfPath:
    echo "configuration file exists alreadly in ", CnfPath
  else:
    echo "init configuration file: ",CnfPath
    cpFile cnfPath, CnfPath
#[ this assues this file runs when it's in source's dic, but in turn maybe is's when it's in installed dir
after install:
  # To ensure `import ./src/pathconsts` works when `uninstall`
  let res = gorgeEx("nimble path arun")
  if res.exitCode == 0:
    let
      path = res.output.strip(leading=false, chars={'\n','\r'}).splitlines[^1]
      afterDir = path/cnfDir
    mkDir afterDir
    cpFile "./src/pathconsts.nim", afterDir
  else:
    echo "Error: arun not installed in nimble"
    echo "result of `nimble path arun` is ", res
]#
proc input(ps: string): string =
  ## no endline returned
  echo ps
  readLineFromStdin()
before uninstall:
  let ps = "remove config file " & CnfPath
  let ans = input(ps&'?'&"default: no") 
  if ans.len != 0 and ans[0] in {'y','Y'}:
    echo ps
    rmFile CnfPath
  

