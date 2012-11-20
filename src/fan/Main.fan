//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

using util

**
** Entry-point to render default HTML view of logs.
**
class Main : AbstractMain
{
  @Arg { help="W3C extended log file format log file to analyze" }
  File? logFile

  @Opt { help="Domain name of website (comma-sep list allowed)" }
  Str domain := ""

  @Opt { help="Write HTML output to directory (defaults to stdout)" }
  File? outDir

  override Int run()
  {
    // check and parse logFile
    if (!logFile.exists) { echo("file not found: $logFile"); return -1 }
    entries := LogReader().read(logFile.in)

    // check domains
    // domains := domain?.split(',')?.map |s| { s.trim } ?: Str#.emptyList

    // only parse the first month of log
    date  := Util.toDate(entries.first["date"].val)
    dates := DateSpan.makeMonth(date)
    entries = entries.findAll |e| { dates.contains(Util.toDate(e["date"].val)) }

    // check out redirect
    out := Env.cur.out
    if (outDir != null)
    {
      name := "webStats-" + (domain.isEmpty ? "" : "$domain-") + date.toLocale("YYYY-MM") + ".html"
      file := outDir + name.toUri
      if (!file.exists) file.create
      out = file.out
      echo("Writing output to $file")
    }

    // render HTML to out
    HtmlRenderer(domain, dates, entries).writeAll(out)
    out.flush
    return 0
  }
}


