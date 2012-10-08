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
class HtmlRenderer
{
  ** Construct new HtmlRenderer for given weblog and render HTML markup
  ** to given output stream.
  new make(LogEntry[] entries)
  {
    this.entries = entries
  }

  ** Entries to render.
  const LogEntry[] entries

  ** Write all HTML content.
  Void writeAll(OutStream out)
  {
    wout := WebOutStream(out)

    wout.w("<!doctype html>").nl
    wout.html
    wout.head.title.w("TODO").titleEnd.headEnd
    wout.body

    VisitorRenderer(this).write(wout)

    wout.bodyEnd
    wout.htmlEnd
  }
}