## for include
#import strutls,os
import std/macros
macro unpack[T](l: openArray[T], vs: varargs[typed]): untyped =
  ## [1,2].unpack(a, b) -> a=1;b=2
  result = newStmtList()
  for i, v in vs:
    let ele = nnkBracketExpr.newTree(l, newLit(i))
    result.add newAssignment(v, ele)

func toExe(name: string): string =
  name.addFileExt ExeExt
template `|=`(s, S: string) =
  if s == "": s = S
template lstrip(s: string, c = ' '): string =
  strip(s, trailing = false, chars = {c})
template splitext(fn: string): seq[string] =
  fn.rsplit(ExtSep, 1)
#[
#now use getAppFilename instead,which has to be placed in `when isMainModue`
template getExePath():untyped=
  if os.fileExists CnfPath:
    CnfPath
  else:
    let exe = lastPathPart paramStr(0)
    os.execProcess when defined(windows):"where "&exe
                   else:"which "exe
]#
template clean(dir: string) =
  #from std/os in line 2456:os.removeDir()
  #but we don't want remove dir
  let
    checkdir = true
  for kind, path in walkDir(dir, checkDir = checkDir):
    case kind
      of pcFile, pcLinkToFile, pcLinkToDir: removeFile(path)
      of pcDir: removeDir(path, true)

template parsecnf =
  if not cnfed:
    (cdict, edict) = readcnf()
#[
template parsecomment:untyped=
  #mixin output,arg
  let
    co=arg.comment.strip()
    f=open(fn,fmAppend)
  if ' ' in co:
    let l=co.splitWhiteSpace()
    let
      pre= l[0]
      suf= l[1]
    f.writeLine('\n',pre,'\n',output,suf)
  else:
    for line in output.splitLines:
      f.writeLine(co,line)
  f.close()
]#

template dumpOpt: untyped =
  echo "parsed from\n  "&CnfPath&"\n"
  for l in CnfPath.lines:
    echo l
  return
const clihelp = slurp"clihelp.txt"
template parseopt: untyped = #in arun
  #mixin argc,argv,addcomment
  var arg: string
  for i in 1..argc:
    arg = paramStr(i)
    case arg:
      #of "-C":addcomment=false
      of "-d", "--dump": dumpOpt()
      of "-D", "--no-delete": ifdel = false
      of "-p", "--purge": removeDir Temp
      of "-h","--help":
        echo clihelp
        quit()
      else: argv.add arg

