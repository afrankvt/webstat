//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   12 Nov 2012  Andy Frank  Creation
//

using web

**
** ReferrerRenderer stats.
**
@Js
class ReferrerRenderer
{
  ** Construct new RefererRenderer for HtmlRenderer.
  new make(HtmlRenderer r)
  {
    this.entries = r.entries

    if (r.domain.startsWith("www."))
    {
      this.self  = "http://" + r.domain["www.".size..-1]
      this.selfw = "http://$r.domain"
    }
    else
    {
      this.self  = "http://$r.domain"
      this.selfw = "http://www.$r.domain"
    }
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    refs   := findRefs
    most   := refs.dup.sortr |a,b| { a.count <=> b.count }
    recent := refs.dup.sortr |a,b| { a.last <=> b.last }

    out.h2("id='referrers'").w("Referrers").h2End
    out.div("class='section'")

    out.h3.w("Top Referrers").h3End
    refChart(out, most)
    refTable(out, most)

    out.h3.w("Recent Referrers").h3End
    refTableRecent(out, recent)

    out.divEnd  // div.section
  }

//////////////////////////////////////////////////////////////////////////
// Analyze
//////////////////////////////////////////////////////////////////////////

  private StatRef[] findRefs()
  {
    map := Str:StatRef[:]
    utc := TimeZone.utc
    ny  := TimeZone("New_York")
    entries.each |e|
    {
      if (!check(e)) return

      uri  := e["cs(Referer)"].val
      ref  := map[uri] ?: StatRef { it.uri=uri }
      date := Util.toDateTime(e)?.date
      time := Time.fromStr(e["time"].val, false)

      DateTime? last
      if (date != null && time != null)
      {
        last = DateTime(
          date.year, date.month, date.day,
          time.hour, time.min, time.sec, 0, utc).toTimeZone(ny)
      }

      ref.count++
      ref.last = last ?: ref.last
      map[uri] = ref
    }
    return map.vals
  }

  ** Return true if valid referrer, false if invalid or
  ** if a search query and should be ignored.
  private Bool check(LogEntry e)
  {
    ref := e["cs(Referer)"]
    if (ref == null) return false
    if (ref.val.startsWith(self)) return false
    if (ref.val.startsWith(selfw)) return false

    // skip but include if not proper uri
    uri := ref.val
    if (!uri.startsWith("http://")) return true

    // find host uri
    off := uri.index("/", 7)
    if (off == null) return true

    // find provider
    host := uri[7..<off].split('.')
    if (host.size < 2) return true
    path := uri[off..-1]

    // white-list providers
    if (host.contains("google")) return false //addTerm("google", "q", path)
    if (host.contains("bing"))   return false //addTerm("bing",   "q", path)
    if (host.contains("yahoo"))  return false //addTerm("yahoo",  "p", path)

    // otherwise normal referrer
    return true
  }

//////////////////////////////////////////////////////////////////////////
// Widgets
//////////////////////////////////////////////////////////////////////////

  private Void refChart(WebOutStream out, StatRef[] refs)
  {
    data := Obj:Int[:]
    end  := refs.size.min(30)
    refs.eachRange(0..<end) |req,i| { data[i+1] = req.count }
    BarPlot(data).write(out)
  }

  private Void refTable(WebOutStream out, StatRef[] refs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := refs.size.min(30)
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Referred").bEnd.tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
      .trEnd
    refs.eachRange(0..<end) |req,i|
    {
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(req.count).tdEnd
        .td("style='$td'").w(toHref(req.uri)).tdEnd
        .trEnd
    }
    out.tableEnd
  }

 private Void refTableRecent(WebOutStream out, StatRef[] refs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := refs.size.min(30)
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("When").bEnd.tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
      .trEnd
    refs.eachRange(0..<end) |req,i|
    {
      date := niceDate(req.last)
      out.tr
        .td("style='$td background:#f8f8f8; text-align:right'").w(date).tdEnd
        .td("style='$td'").w(toHref(req.uri)).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  private Str toHref(Str uri)
  {
    "<a href='$uri.toXml' rel='noreferrer'>$uri.toXml</a>"
  }

  private Str niceDate(DateTime ts)
  {
    // mins
    diff := DateTime.now - ts
    if (diff < 1min)  return "Just now"
    if (diff < 2min)  return "1 min ago"
    if (diff < 1hr)   return "$diff.toMin mins ago"

    // today
    today := Date.today
    if (ts.date == today)
      return "Today " + ts.toLocale("k:mmaa")

    // yesterday
    if (ts.date == (today-1day))
      return "Yesterday"

    // date
    return ts.toLocale(ts.year == today.year ? "WWW D MMM" : "WWW D MMM YYYY")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private const LogEntry[] entries
  private const Str self   // this domain w/o www prefix
  private const Str selfw  // this domain w/ www prefix
}

**************************************************************************
** StateRef
**************************************************************************
@Js
internal class StatRef
{
  Str uri   := ""
  Int count := 0
  DateTime last := DateTime.defVal
}