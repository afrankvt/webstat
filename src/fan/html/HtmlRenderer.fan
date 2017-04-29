//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//   30 Jun 2014  Andy Frank  Refactor to stream design
//

using web

**
** HtmlRenderer renders an HTML page for an analyzed web log.
**
@Js
class HtmlRenderer
{
  ** Construct new HtmlRenderer for given weblog and render HTML markup
  ** to given output stream.
  new make(Str domain, DateSpan dates, LogProc[] procs)
  {
    this.domain = domain
    this.dates = dates
    this.procs = procs
  }

  ** Domain name for site.
  const Str domain

  ** Date span.
  const DateSpan dates

  ** LogProcs to render.
  LogProc[] procs

  ** Write all HTML content.
  Void writeAll(OutStream out)
  {
    wout := WebOutStream(out)
    prev := (dates.start - 1day).firstOfMonth.toLocale("YYYY-MM")
    next := (dates.end + 1day).firstOfMonth.toLocale("YYYY-MM")
    prevDis := Date.fromStr("$prev-01").toLocale("MMM-YYYY")
    nextDis := Date.fromStr("$next-01").toLocale("MMM-YYYY")

    wout.w("<!doctype html>").nl
    wout.html
    wout.head
      .title.w("$domain.toXml &ndash; $dates.dis").titleEnd
      .style.w(
        "body { font: 16px Helvetica Neue, Arial, sans-serif; padding: 0; margin: 0; }

         div.header {
           background: #eee;
           margin: 1em 1em 2em 1em;
           padding: 0 1em 1em 1em;
           border: 1px solid #ccc;
         }
         div.header h1 { margin-bottom: 0; }
         div.header h1 + ul { float: right; padding-right: 1em; }
         div.header ul { list-style: none; padding: 0; margin: 0; }
         div.header ul li { display: inline-block; padding: 0; margin: 0 1em 0 0; }

         h2 { margin: 1em; border-bottom: 1px solid #ccc; }
         div.section { margin: 1em 1em 1em 2em; }
         div.section ul span { display:inline-block; width: 150px; }
         div.section table { margin:1em 0; font-size: 14px; }

         table.rank { margin: 1em 0; border-collapse: collapse; }
         table.rank tr:first-child td { background: #f8f8f8; font-weight: bold; }
         table.rank td { padding: 2px 6px; border: 1px solid #ccc; white-space: nowrap; }
         table.rank td:nth-child(2) { text-align: right; }
         table.rank td:nth-child(3) { width: 100px; }
         table.rank td div { background: #ccc; height: 12px; }

         div.bar-plot {
           height: 300px;
           margin: 1em 0;
           position: relative;
           border: 1px solid #ccc;
           padding: 6px;
         }
         div.bar-plot table {
           position: absolute;
           width: 300px;
           margin-top: 300px;
           -webkit-transform: rotate(-90deg);
              -moz-transform: rotate(-90deg);
                   transform: rotate(-90deg);
           -webkit-transform-origin: 0 0;
              -moz-transform-origin: 0 0;
                   transform-origin: 0 0;
         }
         div.bar-plot table  div { height: 20px; background: #4e8adb; }
         div.bar-plot table div.alt { background: #3762b9; }
         div.bar-plot table  td { white-space: nowrap; }
         div.bar-plot table  td:first-child { text-align: right; }
         div.bar-plot table  td:nth-child(2) { background: #f5f5f5; width: 100%; }
         ").styleEnd
      .headEnd
    wout.body

    wout
      .div("class='header'")
      .h1.w("$domain.toXml &ndash; $dates.dis").h1End
      .ul
        .li.a(`webStats-$domain-${prev}.html`).w("&#x2190; $prevDis").aEnd.liEnd
        .li.a(`webStats-$domain-${next}.html`).w("$nextDis &#x2192;").aEnd.liEnd
        .ulEnd
      .ul
        .li.a(`#summary`).w("Summary").aEnd.liEnd
        .li.a(`#reqs`).w("Requests").aEnd.liEnd
        .li.a(`#visitors`).w("Visitors").aEnd.liEnd
        .li.a(`#referrers`).w("Referrers").aEnd.liEnd
        .li.a(`#search`).w("Search").aEnd.liEnd
        .li.a(`#social`).w("Social").aEnd.liEnd
        .li.a(`#userAgents`).w("User-Agents").aEnd.liEnd
        .ulEnd
      .divEnd // div.header

    SummaryRenderer(procs).write(wout)
    procs.each |p|
    {
      if (p is RequestProc)   RequestRenderer(p).write(wout)
      if (p is VisitorProc)   VisitorRenderer(p).write(wout)
      if (p is ReferrerProc)  ReferrerRenderer(p).write(wout)
      if (p is UserAgentProc) UserAgentRenderer(p).write(wout)
    }

    wout.bodyEnd
    wout.htmlEnd
  }
}