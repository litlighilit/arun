import std/[strutils, os, osproc]
include ./util

proc arun*()
const
  Cnffn = "Acnf.cnf"
  #CnfPath=Cnffn.absolutePath
when isMainModule:
  let CnfPath = getAppFilename()/../Cnffn
  arun()
const
  Csep = ';'
  Esep = ','
  Home = getHomeDir()
  Temp = Home&".aruncache"
  Ocmd = "-o"
  Comment = "#"
  POption = {poStderrToStdout, poUsePath, poEvalCommand,
           poParentStreams
  }
type
  CArgs = tuple[
    c, ext, comment, o, cachecmd: string
  ]
  CDict = seq[CArgs]
  EArgs = tuple[
    c, ext, comment: string
  ]
  EDict = seq[EArgs]
#let CnfPath=getAppFilename()/../Cnffn#paramStr(0).absolutePath.parentDir/Cnffn
# if declared here, `CnfPath` is somehow ""(empty string)
var
  cnfed* = false
  cdict*: CDict
  edict*: Edict

proc warnskipline(noline: Natural, line: string) =
  var msg = "in "&Cnffn&":\n"
  msg.add "  line " &
          $noline&": "&line&'\n'
  msg.add "  !bad format,skip this\n"
  echo msg

proc readcnf(cnf: string = CnfPath): (CDict, EDict) =
  var
    ccmd, ext, comment, ocmd, cacmd: string
    ls: seq[string]
  var no = 1
  for l in cnf.lines:
    defer: inc no
    if l == "" or l.lstrip(' ').startswith(Comment): continue

    if Esep in l:
      ls = l.split(Esep)
      if ls.len notin 1..3:
        warnskipline(no, l)
        continue
      ls.setLen 3
      (ccmd, ext, comment) = ls
      comment |= Comment
      ext = ext.strip.lstrip('.')
      result[1].add (ccmd, ext, comment)

    elif Csep in l:
      ls = l.split(Csep)
      if ls.len notin 1..5:
        warnskipline(no, l)
        continue
      ls.setLen 5
      (ccmd, ext, comment, ocmd, cacmd) = ls
      ocmd |= Ocmd
      comment |= Comment
      ext = ext.strip.lstrip('.')
      result[0].add (ccmd, ext, comment, ocmd, cacmd)

proc run*(fn: string #,addcomment=true
) =
  var cmd, cacmd: string

  let
    l = fn.splitext()
    exe = l[0]
    etype = l[1]
  parsecnf()
  for arg in cdict:
    if arg.ext == etype:
      let
        pureExe = exe.lastPathPart
        o = Temp/pureExe.toExe
        oc = arg.o&o
      if arg.cachecmd != "":
        cacmd = arg.cachecmd&Temp
      #if fn.parentDir.getFilePermissions.contains fpOthers
      cmd = [arg.c, cacmd, oc, fn].join(" ")
      let p = startProcess(cmd, options = POption)
      if p.waitForExit() == 0: #os.fileExists(o):
        os.setFilePermissions(o, {fpUserExec})
        let p2run = startProcess(o, options = POption,
            workingDir = fn.parentDir)
        discard p2run.waitForExit()
        p2run.close()
      p.close()
      return
  for arg in edict:
    if arg.ext == etype:
      cmd = [arg.c, fn].join(" ")
      #debugEcho cmd
      let p = startProcess(cmd, options = POption)
      discard p.waitForExit()
      p.close()
      #if addcomment:parsecomment()
      return
  echo "no "&etype&" found in "&Cnffn

proc arun*() =
  mktemp()
  var
    addcomment = true
    ifdel = true
    fn: string
    argc = paramCount()
    argv: seq[string]
  if argc == 0:
    addcomment = false
    echo "type filename:"
    fn = stdin.readline()
    while fn != "":
      run(fn)
      fn = stdin.readline()
    clean()
    return
  parseopt()
  parsecnf()
  #debugEcho argv
  for fn in argv:
    run(fn
    )
  if ifdel: clean()
