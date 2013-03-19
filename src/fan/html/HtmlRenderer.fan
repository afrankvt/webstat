//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
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
  new make(Str domain, DateSpan dates, LogEntry[] entries, |This|? f := null)
  {
    this.domain = domain
    this.dates = dates
    this.entries = entries
    if (f != null) f(this)
  }

  ** Domain name for site.
  const Str domain

  ** Date span.
  const DateSpan dates

  ** Entries to render.
  const LogEntry[] entries

  ** Cookie name to use for uniques, or use IP if not specified.
  const Str? unique

  ** Write all HTML content.
  Void writeAll(OutStream out)
  {
    wout := WebOutStream(out)
    prev := (dates.start - 1day).firstOfMonth.toLocale("YYYY-MM")
    next := (dates.end + 1day).firstOfMonth.toLocale("YYYY-MM")

    wout.w("<!doctype html>").nl
    wout.html
    wout.head
      .title.w("$domain.toXml &ndash; $dates").titleEnd
      .style.w(
        "body { font: 10pt Helvetica Neue, Arial, sans-serif; padding: 0; margin: 0; }

         div.header {
           position: fixed;
           top: 0; width: 100%;
           padding: 1em;
           background: #fff;
           border-bottom: 1px solid #999;
           box-shadow: #ccc 0px 3px 6px;
           z-index:100;
         }
         div.header h1 { margin: 0 0 0.5em 0; }
         div.header h1 + ul { float: right; padding-right: 1em; }
         div.header ul { list-style: none; padding: 0; margin: 0; font-size: 120%; }
         div.header ul li { display: inline-block; padding: 0; margin: 0 1em 0 0; }
         div.header + h2 { margin-top: 125px; }

         h2 { margin:1em; border-bottom: 1px solid #ccc; }
         div.section { margin: 1em 1em 1em 2em; }
         div.section table { margin:1em 0; }

         div.bar-plot {
           height: 300px;
           margin: 1em 0;
           position: relative;
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
      .h1.w("$domain.toXml &ndash; $dates").h1End
      .ul
        .li.a(`webStats-$domain-${prev}.html`).w("< $prev").aEnd.liEnd
        .li.a(`webStats-$domain-${next}.html`).w("$next >").aEnd.liEnd
        .ulEnd
      .ul
        .li.a(`#visitors`).w("Visitors").aEnd.liEnd
        .li.a(`#referrers`).w("Referrers").aEnd.liEnd
        .li.a(`#userAgents`).w("User-Agents").aEnd.liEnd
        .ulEnd
      .divEnd // div.header

    VisitorRenderer(this).write(wout)
    ReferrerRenderer(this).write(wout)
    UserAgentRenderer(this).write(wout)

    wout.bodyEnd
    wout.htmlEnd
  }
}