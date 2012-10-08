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
class VisitorRenderer
{
  ** Construct new HtmlRenderer for given weblog and render HTML markup
  ** to given output stream.
  new make(HtmlRenderer r)
  {
    this.entries = r.entries.findAll |e|
    {
      stem := e["cs-uri-stem"]?.val
      if (stem == null) return false

      if (stem.endsWith(".css")) return false
      if (stem.endsWith(".png")) return false
      if (stem.endsWith(".gif")) return false
      if (stem.endsWith(".js"))  return false
      return true
    }
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    pageViews := toPageViews("2012-06")
    uniques   := toUniques("2012-06")
    reqs      := toReqs
    mostReqs  := reqs.sortr |a,b| { a.count <=> b.count }

    out.h1.w("Visitors").h1End
    out.h2.w("Page Views").h2End
    out.p.w("Total pageviews this month: $entries.size.toLocale").pEnd
    BarPlot(pageViews).write(out)

    out.h2.w("Unique Visitors").h2End
    out.p.w("Total unique visitors this month: $totalUnique.toLocale").pEnd
    BarPlot(uniques).write(out)

    out.h2.w("Most Requested Pages").h2End
    // mostReqChart(mostReqs),
    // mostReqTable(mostReqs),
  }

//////////////////////////////////////////////////////////////////////////
// Page Views
//////////////////////////////////////////////////////////////////////////

  private Obj:Int toPageViews(Str month)
  {
    m := Obj:Int[:] { ordered=true }
    d := Date.fromLocale("${month}-01", "YYYY-MM-DD")
    d.month.numDays(d.year).times |i| { m[i+1] = 0 }
    entries.each |entry|
    {
      v := toDate(entry["date"]?.val)
      if (v == null) return
      m[v.day] = m[v.day] + 1
    }
    return m
  }

//////////////////////////////////////////////////////////////////////////
// Unique Visitors
//////////////////////////////////////////////////////////////////////////

  private Obj:Int toUniques(Str month)
  {
    counted := Str:[Date:Bool][:] // ipAddr:Date
    data    := Obj:Int[:]
    thisMonth := Date.fromLocale("${month}-01", "YYYY-MM-DD")
    thisMonth.month.numDays(thisMonth.year).times |i| { data[i+1] = 0 }

    entries.each |entry|
    {
      // check for valid ip
      ipEntry := entry["cs(X-Real-IP)"] ?: entry["c-ip"]
      ip := ipEntry==null ? null : ipEntry.val  // workaround for safe field bug
      if (ip == null) return

      // check for valid date
      date := toDate(entry["date"]?.val)
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
    map := Str:Int[:]
    entries.each |e|
    {
      uri := e["cs-uri-stem"].val
      map[uri] = (map[uri] ?: 0) + 1
    }
    return map.keys.map |k| {  StatReq { uri=k; count=map[k] }}
  }

  // private Widget mostReqChart(StatReq[] reqs)
  // {
  //   data := Obj:Int[:]
  //   end  := reqs.size.min(30)
  //   reqs.eachRange(0..<end) |req,i| { data[i+1] = req.count }
  //   return BarChart(data)
  // }
  //
  // private Widget mostReqTable(StatReq[] reqs)
  // {
  //   buf := StrBuf()
  //   out := WebOutStream(buf.out)
  //   td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
  //
  //   end := reqs.size.min(30)
  //   out.table("style='border-spacing: 0px; border-collapse: collapse;'")
  //     .tr
  //     .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
  //     .td("style='$td background:#f8f8f8; text-align:right'").b.w("Reqs").bEnd.tdEnd
  //     .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
  //     .trEnd
  //   reqs.eachRange(0..<end) |req,i|
  //   {
  //     out.tr
  //       .td("style='$td'").w("${i+1}.").tdEnd
  //       .td("style='$td background:#f8f8f8; text-align:right'").w(req.count).tdEnd
  //       .td("style='$td'").w(req.uri.toXml).tdEnd
  //       .trEnd
  //   }
  //   out.tableEnd
  //
  //   return HtmlPane { html=buf.toStr }
  // }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Date? toDate(Str? val)
  {
    if (val == null) return null
    return Date.fromLocale(val, "YYYY-MM-DD", false) ?:
           Date.fromLocale(val, "DD-MM-YYYY", false)
  }

  private LogEntry[] entries
  private Int totalUnique := 0
}

**************************************************************************
** StatReq
**************************************************************************
internal class StatReq
{
  Str uri   := ""
  Int count := 0
}