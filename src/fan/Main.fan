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
    date  := Util.toDate(entries.first["date"].val)
    dates := DateSpan.makeMonth(date)
    entries = entries.findAll |e| { dates.contains(Util.toDate(e["date"].val)) }
    HtmlRenderer(domain, dates, entries).writeAll(out)

    out.flush
    return 0
  }

  Void help()
  {
    echo("webStats $typeof.pod.version")
    echo("usage: fan webStats <domain> <logfile> [outputHtml]")
    echo("  domain:      Domain name of website")
    echo("  logfile:     W3C extended log file format log file")
    echo("  outputHtml:  File to output HTML, or stdout if not given")
  }
}


