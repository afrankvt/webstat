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
// Time Utils
//////////////////////////////////////////////////////////////////////////

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