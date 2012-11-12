//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

**
** Entry-point to render default HTML view of logs.
**
class Main
{
  Int main()
  {
    if (Env.cur.args.size < 1) { help; return -1 }

    log := Env.cur.args.first.toUri.toFile
    if (!log.exists) { echo("file not found: $log"); return -1 }

    file := Env.cur.args.getSafe(1)
    out  := file?.toUri?.toFile?.out ?: Env.cur.out

    domain  := "fantom.org"
    entries := LogReader().read(log.in)

    // TODO FIXIT: walk over each month
    date  := Date.fromLocale(entries.first["date"].val, "DD-MM-YYYY")
    dates := DateSpan.makeMonth(date)
    entries = entries.findAll |e| { dates.contains(Date.fromLocale(e["date"].val, "DD-MM-YYYY")) }
    HtmlRenderer(domain, dates, entries).writeAll(out)
    return 0
  }

  Void help()
  {
    echo("webLogView $typeof.pod.version")
    echo("usage: fan webLogView <logfile> [outputHtml]")
    echo("  logfile:     W3C extended log file format log file")
    echo("  outputHtml:  File to output HTML, or stdout if not given")
  }
}


