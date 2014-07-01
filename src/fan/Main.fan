//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//    8 Oct 2012  Andy Frank  Creation
//   27 Jun 2014  Andy Frank  Refactor to stream design
//

using util

**
** Entry-point to render default HTML view of logs.
**
class Main : AbstractMain
{
  @Arg { help="W3C extended log file format log file to analyze" }
  File? logFile

  @Opt { help="Month to process (defaults to this month)" }
  Str month := Date.today.toLocale("YYYY-MM")

  @Opt { help="Domain name of website" }
  Str domain := ""

  @Opt { help="Write HTML output to directory (defaults to stdout)" }
  File? outDir

  @Opt { help="Cookie name to use for comparing unique users (default uses IP)" }
  Str? unique

  override Int run()
  {
    // check logFile
    if (!logFile.exists) { echo("file not found: $logFile"); return -1 }

    // check domains
    // domains := domain?.split(',')?.map |s| { s.trim } ?: Str#.emptyList

    dates := DateSpan(Date.fromStr("$month-01"))
    nump  := 0
    numa  := 0
    start := Duration.now
    procs := [
      RequestProc   { it.dates=dates },
      VisitorProc   { it.dates=dates; it.uniqueKey=this.unique },
      ReferrerProc  { it.domain=this.domain },
      UserAgentProc {},
    ]

    // iterate over logfile
    LogReader(logFile.in).each |e|
    {
      // ignore out-of-bound dates
      if (!dates.contains(e.ts.date)) return

      // allow each LogProc to process entry
      procs.each |p| { p.process(e) }
    }

    // check out redirect
    out := Env.cur.out
    if (outDir != null)
    {
      name := "webStats-" + (domain.isEmpty ? "" : "$domain-") + dates.start.toLocale("YYYY-MM") + ".html"
      file := outDir + name.toUri
      if (!file.exists) file.create
      out = file.out
      echo("Writing output to $file")
    }

    // render HTML to out
    HtmlRenderer(domain, dates, procs).writeAll(out)
    out.flush
    return 0
  }

  Void info(Str msg)
  {
    echo(msg)
  }
}


