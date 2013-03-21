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
    this.unique = r.unique
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

    numDays  := dates.end > Date.today ? Date.today.day : dates.end.lastOfMonth.day
    avgViews := (entries.size.toFloat / numDays.toFloat).round.toInt
    avgUnique := (totalUnique.toFloat / numDays.toFloat).round.toInt

    out.h2("id='visitors'").w("Visitors").h2End
    out.div("class='section'")

    out.h3.w("Page Views").h3End
    out.p.w("Total pageviews this month: $entries.size.toLocale &ndash; Average: $avgViews.toLocale/day").pEnd
    writeBarPlot(out, pageViews)

    out.h3.w("Unique Visitors").h3End
    out.p.w("Total unique visitors this month: $totalUnique.toLocale &ndash; Average: $avgUnique.toLocale/day").pEnd
    writeBarPlot(out, uniques)

    out.h3.w("Most Requested Pages").h3End
    mostReqTable(out, mostReqs)

    out.divEnd  // div.section
  }

//////////////////////////////////////////////////////////////////////////
// Page Views
//////////////////////////////////////////////////////////////////////////

  private Obj:Int toPageViews()
  {
    m := Obj:Int[:] { ordered=true }
    dates.numDays.times |i| { m[dates.start + Duration(i*1day.ticks)] = 0 }
    entries.each |entry|
    {
      v := Util.toDateTime(entry)?.date
      if (v == null) return
      m[v] = m[v] + 1
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
    dates.numDays.times |i| { data[dates.start + Duration(i*1day.ticks)] = 0 }

    entries.each |entry|
    {
      // check for unqiue value to compare
      val := uniqueVal(entry)
      if (val == null) return

      // check for valid date
      date := Util.toDateTime(entry)?.date
      if (date == null) return

      // verify this ip not counted yet
      byDate := counted[val]
      if (byDate == null) counted[val] = byDate = Date:Bool[:]
      else if (byDate[date] == true) return

      byDate[date] = true          // mark counted
      data[date] = data[date] + 1  // inc count
    }

    totalUnique = counted.size   // set unique for this month
    return data
  }

  private Str? uniqueVal(LogEntry entry)
  {
    // check cookie
    if (unique != null)
    {
      try
      {
        str := (entry["cs(Cookie)"]?.val ?: "").replace("\"\"", "\"")
        map := MimeType.parseParams(str)
        return map[unique]
      }
      catch { return null }
    }

    // fallback to IP
    ipEntry := entry["cs(X-Real-IP)"] ?: entry["c-ip"]
    return ipEntry?.val
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

  private Void mostReqTable(WebOutStream out, StatReq[] reqs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := reqs.size.min(40)
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Reqs").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; width:100px;'").tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
      .trEnd
    reqs.eachRange(0..<end) |req,i|
    {
      p := (req.count.toFloat / reqs.first.count.toFloat * 100f).toInt
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(req.count.toLocale).tdEnd
        .td("style='$td background:#f8f8f8;'")
          .div("style='background:#ccc; height: 12px; width:${p}%;'").divEnd
          .tdEnd
        .td("style='$td'").w(req.uri.toXml).tdEnd
        .trEnd
    }
    out.tableEnd
  }

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

  private Void writeBarPlot(WebOutStream out, Date:Int map)
  {
    max := map.vals.max.toFloat
    max += (max * 0.1f)

    out.div("class='bar-plot'")
    out.table
    map.each |v,k|
    {
      p := (v.toFloat / max * 100f).toInt
      w := k.weekday
      c := w == Weekday.sun ? "class='alt'" : ""
      out.tr
        .td.esc(k.toLocale("WWW M-DD")).tdEnd
        .td.div("$c style='width:${p}%'").divEnd.tdEnd
        .td.w(v.toLocale).tdEnd
        .trEnd
    }
    out.tableEnd
    out.divEnd   // div.bar-plot
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private const DateSpan dates
  private const Str? unique
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