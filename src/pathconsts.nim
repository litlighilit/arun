## path constants of configuration
import std/os
const
  CnfFn* = "arun.cnf"
  CnfDir{.strdefine.} = getConfigDir()
  CnfPath* = CnfDir/CnfFn
  AltCnfDir*{.strdefine.} = "."
  Temp* = getTempDir()&".aruncache"


