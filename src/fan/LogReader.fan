//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

**
** LogReader is used to read log files conforming to the W3C
** extended log file format.
**
@Js
class LogReader
{
  **
  ** Read the log file from input stream.
  **
  LogEntry[] read(InStream in)
  {
    this.in = in
    this.acc = LogEntry[,]
    readLine
    while (line != null) readLine
    return acc
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  ** Read next line.
  private Void readLine()
  {
    try
    {
      lineNum++
      line = in.readLine
      if (line == null) return
      if (line.startsWith("#")) parseDirective
      else parseEntry
    }
    catch (Err err) { echo("$lineNum: $err.traceToStr") }
  }

//////////////////////////////////////////////////////////////////////////
// Directives
//////////////////////////////////////////////////////////////////////////

  ** Parse directive.
  private Void parseDirective()
  {
    off  := line.index(" ")
    if (off == null) return

    name := line[0..<off]
    val  := line[off+1..-1]
    if (name.startsWith("#Fields")) parseFields(val)
  }

  ** Parse field definitions.
  private Void parseFields(Str val)
  {
    fields = val.trim.split
  }

//////////////////////////////////////////////////////////////////////////
// Entries
//////////////////////////////////////////////////////////////////////////

  ** Parse an entry line.
  private Void parseEntry()
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
    acc.add(LogEntry { it.fields=temp })
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
        while (end<size-1 && s[end+1] != '\"') end++
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

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private InStream? in      // input stream
  private LogEntry[]? acc   // cur entries list
  private Str[]? fields     // cur fields
  private Str? line         // cur line
  private Int lineNum       // cur line num
}

**************************************************************************
** LogEntry models a entry from a log file.
**************************************************************************
@Js
const class LogEntry
{
  ** Constructor
  new make(|This|? b) { if (b != null) b(this) }

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


