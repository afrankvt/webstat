#! /usr/bin/env fan
//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

using build

**
** Build: webStats
**
class Build : BuildPod
{
  new make()
  {
    podName = "webStats"
    summary = "W3C Extended Log Analyzer"
    version = Version("1.0")
    depends = ["sys 1.0", "util 1.0", "concurrent 1.0", "web 1.0"]
    srcDirs = [`fan/`, `fan/html/`, `fan/proc/`]
  }
}