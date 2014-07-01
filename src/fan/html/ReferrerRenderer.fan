//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   12 Nov 2012  Andy Frank  Creation
//   30 Jun 2014  Andy Frank  Refactor to stream design
//

using web

**
** ReferrerRenderer stats.
**
@Js
class ReferrerRenderer
{
  ** Construct new RequestRenderer for HtmlRenderer.
  new make(ReferrerProc p)
  {
    this.p = p
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    stats  := p.stats
    most   := stats.dup.sortr |a,b| { a.count <=> b.count }
    recent := stats.dup.sortr |a,b| { a.last <=> b.last }

    sstats  := p.socialStats
    smost   := sstats.dup.sortr |a,b| { a.count <=> b.count }
    srecent := sstats.dup.sortr |a,b| { a.last <=> b.last }

    out.h2("id='referrers'").w("Referrers").h2End
    out.div("class='section'")
      out.h3.w("Top Referrers").h3End;    refTable(out, most)
      out.h3.w("Recent Referrers").h3End; refTableRecent(out, recent)
      out.divEnd

    out.h2("id='search'").w("Search").h2End
    out.div("class='section'")
      out.h3.w("Search Providers").h3End; refTableSearch(out)
      out.h3.w("Search Terms").h3End;     refTableSearchTerms(out)
      out.divEnd

    out.h2("id='social'").w("Social").h2End
    out.div("class='section'")
      out.h3.w("Social Networks").h3End;         refTableSocial(out)
      out.h3.w("Top Social Referrers").h3End;    refTable(out, smost)
      out.h3.w("Recent Social Referrers").h3End; refTableRecent(out, srecent)
      out.divEnd
  }

  private Void refTable(WebOutStream out, ReferrerStat[] refs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := refs.size.min(40)
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Referred").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; width:100px;'").tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Page").bEnd.tdEnd
      .trEnd
    refs.eachRange(0..<end) |req,i|
    {
      p := (req.count.toFloat / refs.first.count.toFloat * 100f).toInt
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(req.count).tdEnd
        .td("style='$td background:#f8f8f8;'")
          .div("style='background:#ccc; height: 12px; width:${p}%;'").divEnd
          .tdEnd
        .td("style='$td'").w(toHref(req.uri)).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  private Void refTableRecent(WebOutStream out, ReferrerStat[] refs)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    end := refs.size.min(40)
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

  private Void refTableSearch(WebOutStream out)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("%").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Count").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; width:100px;'").tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Provider").bEnd.tdEnd
      .trEnd

    sum  := ((Int)p.search.vals.reduce(0) |Int r, Int v->Int| { r + v }).toFloat
    keys := p.search.keys.sortr |a,b| { p.search[a] <=> p.search[b] }
    keys.each |key,i|
    {
      v := p.search[key]
      p := (v.toFloat / sum * 100f)
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(p.toLocale("0.00")).w("%").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(v.toLocale).tdEnd
        .td("style='$td background:#f8f8f8;'")
          .div("style='background:#ccc; height: 12px; width:${p.toInt}%;'").divEnd
          .tdEnd
        .td("style='$td'").w(key.toDisplayName).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  private Void refTableSearchTerms(WebOutStream out)
  {
    if (p.searchTerms.isEmpty) return

    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Count").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; width:100px;'").tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Term").bEnd.tdEnd
      .trEnd

    max  := p.searchTerms.vals.max.toFloat
    keys := p.searchTerms.keys.sortr |a,b| { p.searchTerms[a] <=> p.searchTerms[b] }
    keys.eachRange(0..<keys.size.min(40)) |key,i|
    {
      v := p.searchTerms[key]
      p := (v.toFloat / max * 100f)
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(v.toLocale).tdEnd
        .td("style='$td background:#f8f8f8;'")
          .div("style='background:#ccc; height: 12px; width:${p.toInt}%;'").divEnd
          .tdEnd
        .td("style='$td'").esc(key).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  private Void refTableSocial(WebOutStream out)
  {
    td  := "padding: 2px 6px; border:1px solid #ccc; white-space:nowrap;"
    out.table("style='margin:1em 0; border-spacing: 0px; border-collapse: collapse;'")
      .tr
      .td("style='$td background:#f8f8f8;'").b.w("Rank").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("%").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; text-align:right'").b.w("Count").bEnd.tdEnd
      .td("style='$td background:#f8f8f8; width:100px;'").tdEnd
      .td("style='$td background:#f8f8f8;'").b.w("Social Network").bEnd.tdEnd
      .trEnd

    sum  := ((Int)p.social.vals.reduce(0) |Int r, Int v->Int| { r + v }).toFloat
    keys := p.social.keys.sortr |a,b| { p.social[a] <=> p.social[b] }
    keys.each |key,i|
    {
      v := p.social[key]
      p := (v.toFloat / sum * 100f)
      out.tr
        .td("style='$td'").w("${i+1}.").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(p.toLocale("0.00")).w("%").tdEnd
        .td("style='$td background:#f8f8f8; text-align:right'").w(v.toLocale).tdEnd
        .td("style='$td background:#f8f8f8;'")
          .div("style='background:#ccc; height: 12px; width:${p.toInt}%;'").divEnd
          .tdEnd
        .td("style='$td'").w(key.toDisplayName).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  private Str toHref(Str uri)
  {
    "<a href='$uri.toXml' style='display:inline-block; max-width:800px;" +
     " overflow:hidden; text-overflow:ellipsis;' rel='noreferrer'>$uri.toXml</a>"
  }

  private Str niceDate(DateTime ts)
  {
    // TODO FIXIT: this only works when stats are generated in real-time...

    // // mins
    // diff := DateTime.now - ts
    // if (diff < 1min)  return "Just now"
    // if (diff < 2min)  return "1 min ago"
    // if (diff < 1hr)   return "$diff.toMin mins ago"
    //
    // // today
    // today := Date.today
    // if (ts.date == today)
    //   return "Today " + ts.toLocale("k:mmaa")
    //
    // // yesterday
    // if (ts.date == (today-1day))
    //   return "Yesterday " + ts.toLocale("k:mmaa")
    //
    // // date
    // return ts.toLocale(ts.year == today.year ? "WWW D MMM" : "WWW D MMM YYYY")

    return ts.toLocale("WWW D MMM k:mmaa")
  }

  private ReferrerProc p
}
