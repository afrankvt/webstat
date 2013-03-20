//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   12 Nov 2012  Andy Frank  Creation
//

using web

**
** UserAgentRenderer renders user agent stats.
**
@Js
class UserAgentRenderer
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Construct new UserAgentRenderer for HtmlRenderer.
  new make(HtmlRenderer r)
  {
    this.entries = r.entries
    this.agents  = entries.findAll |e| { e.has("cs(User-Agent)") }
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    analyzeUserAgents

    out.h2("id='userAgents'").w("User-Agents").h2End
    out.div("class='section'")

    out.h3.w("Browser Usage").h3End
    browserChart(out)
    browserTable(out)

    out.divEnd  // div.section
  }

//////////////////////////////////////////////////////////////////////////
// Analyze
//////////////////////////////////////////////////////////////////////////

  private Void analyzeUserAgents()
  {
    sets = Str:StatAgentSet[:]
    sets["Firefox"] = StatAgentSet { name="Firefox" }
    sets["Android"] = StatAgentSet { name="Android" }
    sets["Chrome"]  = StatAgentSet { name="Chrome" }
    sets["Safari"]  = StatAgentSet { name="Safari" }
    sets["Opera"]   = StatAgentSet { name="Opera" }
    sets["IE"]      = StatAgentSet { name="IE" }
    sets["Mobile Safari"] = StatAgentSet { name="Mobile Safari" }
    sets["Other"]   = StatAgentSet { name="Other" }

    // sort agents by product and version
    agents.each |agent|
    {
      ua := UserAgent(agent["cs(User-Agent)"].val)

      // check comments
      comment := ua.comments.find |c|
      {
        if (c.startsWith("Android ")) { count("Android", c["Android ".size..-1]); return true }
        if (c.startsWith("MSIE "))    { count("IE", c["MSIE ".size..-1]); return true }
        return false
      }

      // bail if comment matched
      if (comment != null) return

      // check products
      product := ua.products.find |p|
      {
        if (p.name == "Firefox") { count("Firefox", p.ver); return true }
        if (p.name == "Chrome")  { count("Chrome",  p.ver); return true }
        if (p.name == "Safari")
        {
          v := ua.products.find |v| { v.name == "Version" }
          m := ua.products.find |m| { m.name == "Mobile" }
          if (v != null)
          {
            if (m != null) count("Mobile Safari", v.ver)
            else count("Safari", v.ver)
          }
          return true
        }
        if (p.name == "Opera")   { count("Opera", p.ver);  return true }
        return false
      }

      // other
      if (product == null) count("Other", "")
    }
  }

  private Void count(Str name, Str ver)
  {
    // set count
    a := sets[name]
    a.num++

    // ver count
    v := a.ver[ver]
    if (v == null)
    {
      v = StatAgent { it.name=name; it.ver=ver }
      a.ver[ver] = v
    }
    v.num++
  }

//////////////////////////////////////////////////////////////////////////
// Browsers
//////////////////////////////////////////////////////////////////////////

  private Str:Int toBrowserData()
  {
    data := Str:Int[:] { ordered=true }
    sorted := sets.vals.sortr |a,b| { a.num <=> b.num }
    sorted.each |v| { data[v.name] = v.num }
    return data
  }

  private Void browserTable(WebOutStream out)
  {
    // sort by usage and list
    sorted := sets.vals.sortr |a,b| { a.num <=> b.num }
    total  := sorted.reduce(0) |Int r,v| { r + v.num }
    out.table("style='border-spacing: 0px; border-collapse: collapse;'")
    sorted.each |a| { row(out, a, total) }
    out.tableEnd
  }

  private Void row(WebOutStream out, StatAgentSet a, Int total)
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

  private Void browserChart(WebOutStream out)
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
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private LogEntry[] entries
  private LogEntry[] agents
  private Str:StatAgentSet sets := [:]

}

@Js
internal class StatAgentSet
{
  Str name := ""
  Int num  := 0
  Str:StatAgent ver := Str:StatAgent[:]
}

@Js
internal class StatAgent
{
  Str name := ""
  Str ver  := ""
  Int num  := 0
}