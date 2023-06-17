## for include
#import strutls,os
func toExe(name: string): string =
  name.addFileExt ExeExt
template `|=`(s,S:string)=
  if s=="":s=S
template lstrip(s:string,c=' '):string=
  strip(s,trailing=false,chars={c})
template splitext(fn:string):seq[string]=
  fn.rsplit(ExtSep,1)
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
template mktemp()=
  #mixin Temp
  createDir(Temp)
template clean()=
  #from std/os in line 2456:os.removeDir()
  #but we don't want remove dir
  mixin Temp
  let
    dir=Temp
    checkdir=true
  for kind, path in walkDir(dir, checkDir = checkDir):
    case kind
      of pcFile, pcLinkToFile, pcLinkToDir: removeFile(path)
      of pcDir: removeDir(path, true)
template parsecnf()=
  if not cnfed:
    (cdict,edict)=readcnf()
#[
template parsecomment():untyped=
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

template dumpOpt():untyped=
  echo "parsed from\n  "&CnfPath&"\n"
  for l in CnfPath.lines:
    echo l
  return
template parseopt():untyped=  #in arun
  #mixin argc,argv,addcomment
  var arg:string
  for i in 1..argc:
    arg=paramStr(i)
    case arg:
      #of "-C":addcomment=false
      of "-d":dumpOpt()
      of "-D":ifdel=false
      of "--purge":removeDir Temp
      else:argv.add arg

