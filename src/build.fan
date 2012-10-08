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
** Build: webLogView
**
class Build : BuildPod
{
  new make()
  {
    podName = "webLogView"
    summary = "W3C Extended Log Analyzer and Viewer"
    version = Version("1.0")
    depends = ["sys 1.0", "util 1.0", "concurrent 1.0", "web 1.0"]
    srcDirs = [`fan/`, `fan/html/`]
  }
}