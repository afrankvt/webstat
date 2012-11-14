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
  new make(Str domain, DateSpan dates, LogEntry[] entries)
  {
    this.domain = domain
    this.dates = dates
    this.entries = entries
  }

  ** Domain name for site..
  const Str domain

  ** Date span.
  const DateSpan dates

  ** Entries to render.
  const LogEntry[] entries

  ** Write all HTML content.
  Void writeAll(OutStream out)
  {
    wout := WebOutStream(out)

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
         div.header ul { list-style: none; padding: 0; margin: 0; font-size: 120%; }
         div.header ul li { display: inline-block; padding: 0; margin: 0 1em 0 0; }
         div.header + h2 { margin-top: 125px; }

         h2 { margin:1em; border-bottom: 1px solid #ccc; }
         div.section { margin: 1em 1em 1em 2em; }
         div.section table { margin:1em 0; }
         ").styleEnd
      .headEnd
    wout.body

    wout
      .div("class='header'")
      .h1.w("$domain.toXml &ndash; $dates").h1End
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