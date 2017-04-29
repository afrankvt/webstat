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
** UserAgentRenderer renders user agent stats.
**
@Js
class UserAgentRenderer
{
  ** Construct new PageRenderer for HtmlRenderer.
  new make(UserAgentProc p)
  {
    this.p = p
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    out.h2("id='userAgents'").w("User-Agents").h2End
      .div("class='section'")
      .h3.w("Browser Usage").h3End
      browserChart(out)
      browserTable(out)
      .divEnd
  }

  private WebOutStream browserChart(WebOutStream out)
  {
    map := toBrowserData
    max := map.vals.max.toFloat
    max += (max * 0.1f)

    out.div("class='bar-plot'")
    out.table
    map.each |v,k|
    {
      p := (v.toFloat / max * 100f).toInt
      out.tr
        .td.esc(k).tdEnd
        .td.div("style='width:${p}%'").divEnd.tdEnd
        .td.w(v.toLocale).tdEnd
        .trEnd
    }
    out.tableEnd
    out.divEnd   // div.bar-plot
    return out
  }

  private Str:Int toBrowserData()
  {
    data := Str:Int[:] { ordered=true }
    sorted := p.sets.vals.sortr |a,b| { a.num <=> b.num }
    sorted.each |v| { data[v.name] = v.num }
    return data
  }

  private WebOutStream browserTable(WebOutStream out)
  {
    // sort by usage and list
    sorted := p.sets.vals.sortr |a,b| { a.num <=> b.num }
    total  := sorted.reduce(0) |Int r,v| { r + v.num }
    out.table("style='border-spacing: 0px; border-collapse: collapse;'")
    sorted.each |a| { row(out, a, total) }
    out.tableEnd
    return out
  }

  private Void row(WebOutStream out, UserAgentSet a, Int total)
  {
    td := "padding: 2px 6px; border:1px solid #ccc;"

    // product stats
    per := ((a.num.toFloat / total.toFloat) * 100f).toLocale("0.00")
    out.tr("style='background:#f8f8f8'")
      .td("style='$td'").b.w(a.name).bEnd.tdEnd
      .td("style='$td; text-align:right'").w(a.num.toLocale).tdEnd
      .td("style='$td; text-align:right'").w("$per%").tdEnd
      .trEnd

    // version stats
    sorted := a.ver.vals.sortr |va,vb| { va.num <=> vb.num }
    sorted.each |v|
    {
      share := (v.num.toFloat / a.num.toFloat) * 100f
      if (share < 1f) return

      per = share.toLocale("0.00")
      out.tr("style='color:#999'")
        .td("style='$td; padding-left:2em'").w(v.ver).tdEnd
        .td("style='$td; text-align:right'").w(v.num.toLocale).tdEnd
        .td("style='$td; text-align:right'").w("$per%").tdEnd
        .trEnd
    }
  }

  private UserAgentProc p
}