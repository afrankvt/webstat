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
    if (Env.cur.args.size < 2) { help; return -1 }

    domain := Env.cur.args[0]
    log := Env.cur.args[1].toUri.toFile
    if (!log.exists) { echo("file not found: $log"); return -1 }

    file := Env.cur.args.getSafe(2)
    out  := file?.toUri?.toFile?.out ?: Env.cur.out
    entries := LogReader().read(log.in)

    // TODO FIXIT: walk over each month?
    date  := Date.fromLocale(entries.first["date"].val, "DD-MM-YYYY")
    dates := DateSpan.makeMonth(date)
    entries = entries.findAll |e| { dates.contains(Date.fromLocale(e["date"].val, "DD-MM-YYYY")) }
    HtmlRenderer(domain, dates, entries).writeAll(out)
    return 0
  }

  Void help()
  {
    echo("webLogView $typeof.pod.version")
    echo("usage: fan webLogView <domain> <logfile> [outputHtml]")
    echo("  domain:      Domain name of website")
    echo("  logfile:     W3C extended log file format log file")
    echo("  outputHtml:  File to output HTML, or stdout if not given")
  }
}


