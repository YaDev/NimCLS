packageName   = "nimcls"
version       = "1.0.2"
author        = "Yaser A"
description   = "Classes and dependency injection for Nim."
license       = "MIT"
skipDirs      = @["examples", "tests"]
srcDir        = "src"

requires: "nim >= 2.0.0"


task test, "Run all tests":
  withDir("tests"):
    exec "nim c -r ./classes.nim"
    exec "nim c -r ./injection.nim"