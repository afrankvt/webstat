//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

**
** LogProc processes a set of log entries.
**
@Js
abstract class LogProc
{
  ** Process the given entry.
  abstract Void process(LogEntry entry)
}