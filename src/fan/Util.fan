//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   14 Nov 2012  Andy Frank  Creation
//

**
** Util methods.
**
@Js
const class Util
{
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

    return date.toDateTime(time, gmt).toTimeZone(tz)
  }

  static const TimeZone gmt := TimeZone("GMT")
}