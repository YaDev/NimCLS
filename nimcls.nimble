packageName   = "nimcls"
version       = "4.2.0"
author        = "Yaser A"
description   = "Classes and dependency injection for Nim."
license       = "MIT"
skipDirs      = @["examples", "tests"]
srcDir        = "src"

requires: "nim >= 2.0.0"


task test, "Run all tests":
  withDir("tests"):
    exec "nim c -r ./macro.nim"
    exec "nim c -r ./classes.nim"
    exec "nim c -r ./classes_static.nim"
    exec "nim c -r ./classes_generic.nim"
    exec "nim c -r ./injection.nim"
    exec "nim c -r ./injection_static.nim"