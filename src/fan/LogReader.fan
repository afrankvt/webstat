//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//    8 Oct 2012  Andy Frank  Creation
//   27 Jun 2014  Andy Frank  Refactor to stream design
//

**
** LogReader is used to read log files conforming to the W3C
** extended log file format.
**
@Js
class LogReader
{
  ** Construct new LogReader for given log input stream.
  new make(InStream in) { this.in = in }

  ** Iterate over the log file and call func for each log entry.
  Void each(|LogEntry| func)
  {
    lineNum := 0
    while ((line = in.readLine) != null)
    {
      lineNum++
      try
      {
        // 8-Oct-2014: server crash generated garbage
        // so just toss out whole line if ever found
        if (line[0] == 0) { /*echo("SKIP: $line");*/ continue }

        if (line.startsWith("#")) parseDirective
        else func(parseEntry)
      }
      catch (Err err)
      {
        echo("[Line $lineNum] $line")
        err.trace
        throw err
      }
    }
  }

  ** Parse directive line.
  private Void parseDirective()
  {
    off  := line.index(" ")
    if (off == null) return

    name := line[0..<off]
    val  := line[off+1..-1]
    if (name.startsWith("#Fields"))
      fields = val.trim.split
  }

 ** Parse an entry line.
  private LogEntry parseEntry()
  {
    if (fields == null) throw ParseErr("Fields not defined")

    temp   := LogField[,]
    tokens := tokenize(line)
    fields.each |f,i|
    {
      if (i >= tokens.size) return
      v := tokens[i]
      if (v == "-") return
      temp.add(LogField { id=f; val=v })
    }

    return LogEntry { it.orig=line; it.fields=temp }
  }

  ** Tokenize string using delimiting on whitespace.
  private Str[] tokenize(Str s)
  {
    tokens := Str[,]
    start  := 0
    size   := s.size

    while (start < size)
    {
      // eat leading whitespace
      while (start<size && s[start] == ' ') start++
      if (start>=size) break
      end := start
      val := ""

      if (s[start] == '\"')
      {
        // parse string
        while (end < size-1)
        {
          // end quote must be followed by space or EOL
          if (s[end+1] == '\"')
          {
            if (end+2 == size) break
            if (s[end+2] == ' ') break
          }
          end++
        }
        val = s[start+1..end]
        end++
      }
      else
      {
        // parse non-string
        while (end<size-1 && s[end+1] != ' ') end++
        val = s[start..end]
      }

      // add token
      start = end + 1
      tokens.add(val)
    }

    return tokens
  }

  private InStream in
  private Str? line         // cur line
  private Str[]? fields     // cur fields
}

**************************************************************************
** LogEntry models a entry from a log file.
**************************************************************************
@Js
const class LogEntry
{
  ** Constructor
  new make(|This|? b)
  {
    if (b != null) b(this)
    this.ts = Util.toDateTime(this)
  }

  ** Parsed timestamp if available.
  const DateTime? ts := null

  ** Return true if entry contains field id.
  Bool has(Str id)
  {
    has := fields.find |f| { f.id == id }
    return has != null
  }

  ** Return the first LogField with id.  If a field
  ** with this id is not found, return null.
  @Operator LogField? get(Str id)
  {
    fields.find |f| { f.id == id }
  }

  ** Original log line.
  const Str orig := ""

  ** The fields for this entry.
  const LogField[] fields := LogField[,]

  override Str toStr() { fields.join(", ") }
}

**************************************************************************
** LogField models a field from a LogEntry.
**************************************************************************
@Js
const class LogField
{
  ** Constructor
  new make(|This|? b) { if (b != null) b(this) }

  ** The field indentifier.
  const Str id := ""

  ** The value of this field.
  const Str val := ""

  override Str toStr() { "$id:$val" }
}


