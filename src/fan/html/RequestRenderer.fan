//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

using web

**
** RequestRenderer renders visitor stats.
**
@Js
class RequestRenderer
{
  ** Construct new RequestRenderer for HtmlRenderer.
  new make(RequestProc p)
  {
    this.p = p
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    numDays  := p.dates.numDays
    avgViews := (p.pages.toFloat / numDays.toFloat).round.toInt

    out.h2("id='reqs'").w("Requests").h2End
    out.div("class='section'")

    out.p
      .w("Total pageviews this month: $p.pages.toLocale &ndash; ")
      .w("Average: $avgViews.toLocale/day")
      .pEnd
    out.p
      .w("Average time taken: ${p.avgTime}ms &ndash; ")
      .w("Min: ${p.minTime}ms  &ndash; ")
      .w("Max: ${p.maxTime}ms")
      .pEnd

    Util.writeBarPlot(out, p.pagesByDate)
    Util.writeBarPlot(out, p.pagesByTime)
    Util.writeBarPlot(out, p.pagesByWeekday)
    // Util.writeBarPlot(out, p.byStatus)

    out.h3.w("Most Requested Sections").h3End
    Util.writeRankTable(out, "Section", p.pagesBySection)

    out.h3.w("Most Requested Pages").h3End;
    Util.writeRankTable(out, "Reqs", p.pagesByReq)
    out.divEnd
  }

  private RequestProc p
}
