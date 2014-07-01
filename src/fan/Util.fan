//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   14 Nov 2012  Andy Frank  Creation
//

using web

**
** Util methods.
**
@Js
const class Util
{

//////////////////////////////////////////////////////////////////////////
// Entry Utils
//////////////////////////////////////////////////////////////////////////

  ** Return true if this is a page entry.
  static Bool isPage(LogEntry entry)
  {
    if (entry.ts == null) return false

    stem := entry["cs-uri-stem"]?.val
    if (stem == null) return false

    if (stem.endsWith(".css")) return false
    if (stem.endsWith(".png")) return false
    if (stem.endsWith(".jpg")) return false
    if (stem.endsWith(".gif")) return false
    if (stem.endsWith(".js"))  return false
    if (stem.endsWith(".ico")) return false
    if (stem == "/robots.txt") return false

    if (!Util.isVisitor(entry)) return false
    return true
  }

  ** Return true if this is a valid visitor.
  static Bool isVisitor(LogEntry entry)
  {
    ua := entry["cs(User-Agent)"]
    if (ua == null) return false
    if (ua.val.startsWith("Pingdom.com_bot")) return false
    return true
  }

  ** Attempt to convert LogEntry into DateTime instance using
  ** 'date' and 'time' entries.  If a DateTime cannot be created,
  ** returns null.
  static DateTime? toDateTime(LogEntry entry, TimeZone tz := TimeZone.cur)
  {
    dstr := entry["date"]?.val
    tstr := entry["time"]?.val
    if (dstr == null || tstr == null) return null

    date := Date.fromLocale(dstr, "YYYY-MM-DD", false) ?:
            Date.fromLocale(dstr, "DD-MM-YYYY", false)
    if (date == null) return null

    time := Time.fromLocale(tstr, "hh:mm:ss", false)
    if (time == null) return null

    return date.toDateTime(time, utc).toTimeZone(tz)
  }

  static const TimeZone utc := TimeZone("UTC")

//////////////////////////////////////////////////////////////////////////
// Render Utils
//////////////////////////////////////////////////////////////////////////

  ** Render a rank table.
  static Void writeRankTable(WebOutStream out, Str col, Obj:Int map)
  {
    // sort and trim keys
    keys := map.keys.sortr |a,b| { map[a] <=> map[b] }
    size := keys.size.min(40)

    out.table("class='rank'")
      .tr
      .td.w("Rank").tdEnd
      .td.esc(col).tdEnd
      .td.tdEnd
      .td.w("Page").tdEnd
      .trEnd
    keys.eachRange(0..<size) |key,i|
    {
      v := map[key]
      p := (v.toFloat / map[keys.first].toFloat * 100f).toInt
      out.tr
        .td.w("${i+1}.").tdEnd
        .td.w(v.toLocale).tdEnd
        .td.div("style='width:${p}%;'").divEnd.tdEnd
        .td.esc(key).tdEnd
        .trEnd
    }
    out.tableEnd
  }

  ** Render a bar plot using given map.
  static Void writeBarPlot(WebOutStream out, Obj:Int map)
  {
    max := map.vals.max.toFloat
    max += (max * 0.1f)

    out.div("class='bar-plot'")
    out.table
    map.each |v,k|
    {
      dis := k.toStr
      per := (v.toFloat / max * 100f).toInt
      cls := ""

      if (k is Date)
      {
        date := (Date)k
        dis = date.toLocale("WWW M-DD")
        if (date.weekday == Weekday.sun) cls = "class='alt'"
      }
      else if (k is Time)
      {
        time := (Time)k
        dis = time.toLocale("k:mm aa")
      }
      else if (k is Weekday)
      {
        w := (Weekday)k
        dis = w.localeFull
      }

      out.tr
        .td.esc(dis).tdEnd
        .td.div("$cls style='width:${per}%'").divEnd.tdEnd
        .td.w(v.toLocale).tdEnd
        .trEnd
    }
    out.tableEnd
    out.divEnd   // div.bar-plot
  }
}