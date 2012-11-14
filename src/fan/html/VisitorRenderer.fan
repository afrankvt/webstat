//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

using web

**
** VisitorRenderer renders visitor stats.
**
@Js
class VisitorRenderer
{
  ** Construct new VisitorRenderer for HtmlRenderer.
  new make(HtmlRenderer r)
  {
    this.dates = r.dates
    this.entries = r.entries.findAll |e|
    {
      stem := e["cs-uri-stem"]?.val
      if (stem == null) return false

      if (stem.endsWith(".css")) return false
      if (stem.endsWith(".png")) return false
      if (stem.endsWith(".jpg")) return false
      if (stem.endsWith(".gif")) return false
      if (stem.endsWith(".js"))  return false
      return true
    }
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    pageViews := toPageViews
    uniques   := toUniques
    reqs      := toReqs
    mostReqs  := reqs.sortr |a,b| { a.count <=> b.count }

    out.h2("id='visitors'").w("Visitors").h2End
    out.div("class='section'")

    out.h3.w("Page Views").h3End
    out.p.w("Total pageviews this month: $entries.size.toLocale").pEnd
    BarPlot(pageViews).write(out)

    out.h3.w("Unique Visitors").h3End
    out.p.w("Total unique visitors this month: $totalUnique.toLocale").pEnd
    BarPlot(uniques).write(out)

    out.h3.w("Most Requested Pages").h3End
    mostReqChart(out, mostReqs)
    mostReqTable(out, mostReqs)

    out.divEnd  // div.section
  }

//////////////////////////////////////////////////////////////////////////
// Page Views
//////////////////////////////////////////////////////////////////////////

  private Obj:Int toPageViews()
  {
    m := Obj:Int[:] { ordered=true }
    dates.numDays.times |i| { m[i+1] = 0 }
    entries.each |entry|
    {
      v := Util.toDate(entry["date"]?.val)
      if (v == null) return
      m[v.day] = m[v.day] + 1
    }
    return m
  }

//////////////////////////////////////////////////////////////////////////
// Unique Visitors
//////////////////////////////////////////////////////////////////////////

  private Obj:Int toUniques()
  {
    counted := Str:[Date:Bool][:]  // ipAddr:Date
    data    := Obj:Int[:] { ordered=true }
    dates.numDays.times |i| { data[i+1] = 0 }

    entries.each |entry|
    {
      // check for valid ip
      ipEntry := entry["cs(X-Real-IP)"] ?: entry["c-ip"]
      ip := ipEntry==null ? null : ipEntry.val  // workaround for safe field bug
      if (ip == null) return

      // check for valid date
      date := Util.toDate(entry["date"]?.val)
      if (date == null) return

      // verify this ip not counted yet
      byDate := counted[ip]
      if (byDate == null) counted[ip] = byDate = Date:Bool[:]
      else if (byDate[date] == true) return

      byDate[date] = true                  // mark counted
      data[date.day] = data[date.day] + 1  // inc count
    }

    totalUnique = counted.size   // set unique for this month
    return data
  }

//////////////////////////////////////////////////////////////////////////
// Requested
//////////////////////////////////////////////////////////////////////////

  private StatReq[] toReqs()
  {
    map := Str:Int[:] { ordered=true }
    entries.each |e|
    {
      uri := e["cs-uri-stem"].val
      map[uri] = (map[uri] ?: 0) + 1
    }
    return map.keys.map |k| {  StatReq { uri=k; count=map[k] }}
  }

  private Void mostReqChart(WebOutStream out, StatReq[] reqs)
  {
    data := Obj:Int[:] { ordered=true }
    end  := reqs.size.min(30)
    reqs.eachRange(0..<end) |req,i| { data[i+1] = req.count }
    BarPlot(data).write(out)
  }

  private Void mostReqTable(WebOutStream out, StatReq[] reqs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := reqs.size.min(30)
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Reqs").bEnd.tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
      .trEnd
    reqs.eachRange(0..<end) |req,i|
    {
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(req.count.toLocale).tdEnd
        .td("style='$td'").w(req.uri.toXml).tdEnd
        .trEnd
    }
    out.tableEnd
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private const DateSpan dates
  private const LogEntry[] entries
  private Int totalUnique := 0
}

**************************************************************************
** StatReq
**************************************************************************
@Js
internal class StatReq
{
  Str uri   := ""
  Int count := 0
}