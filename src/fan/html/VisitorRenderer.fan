//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//  28 Jun 2014  Andy Frank  Refactor to stream design
//

using web

**
** VisitorRenderer renders visitor stats.
**
@Js
class VisitorRenderer
{
  ** Construct new VisitorRenderer for HtmlRenderer.
  new make(VisitorProc p)
  {
    this.p = p
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    days := p.dates.numDays
    avg  := (p.total.toFloat / days.toFloat).round.toInt

    out.h2("id='visitors'").w("Visitors").h2End
    out.div("class='section'")
      out.p
        .w("Total visitors this month: $p.total.toLocale &ndash; ")
        .w("Average: $avg.toLocale/day")
        .pEnd
      Util.writeBarPlot(out, p.byDate)
      out.divEnd
  }

  private VisitorProc p
}
