//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

**
** VisitorProc processes visitor traffic.
**
@Js
class VisitorProc : LogProc
{
  ** It-block ctor.
  new make(|This| f)
  {
    f(this)
    dates.numDays.times |i| { byDate[dates.start + Duration(i*1day.ticks)] = 0 }
  }

  ** Dates for this proc.
  const DateSpan dates

  ** Cookie name to use for uniques, or use IP if not specified.
  const Str? uniqueKey

  ** Total visitors.
  Int total := 0

  ** Total unique visitors.
  Int uniques := 0

  ** Visitors by date.
  Date:Int byDate := Date:Int[:] { ordered=true }

  ** Unknown entries.
  Int unknown := 0

  override Void process(LogEntry entry)
  {
    // skip non visitors
    if (!Util.isVisitor(entry)) return

    date := entry.ts.date
    uval := uniqueVal(entry)
    if (uval == null) unknown++
    else
    {
      // total
      if (uniqueMap[uval] == null)
      {
        uniques++
        uniqueMap[uval] = true
      }

      // by date
      dates := uniqueDateMap[date] ?: Str:Bool[:]
      if (dates[uval] == null)
      {
        total++
        dates[uval] = true
        byDate[date] = byDate[date] + 1
        uniqueDateMap[date] = dates
      }
    }
  }

  ** Get unique value for this entry.
  private Str? uniqueVal(LogEntry entry)
  {
    // check cookie
    if (uniqueKey != null)
    {
      try
      {
        str := (entry["cs(Cookie)"]?.val ?: "").replace("\"\"", "\"")
        map := MimeType.parseParams(str)
        return map[uniqueKey]
      }
      catch { return null }
    }

    // fallback to IP
    ipEntry := entry["cs(X-Real-IP)"] ?: entry["c-ip"]
    return ipEntry?.val
  }

  private Str:Bool uniqueMap := [:]
  private Date:[Str:Bool] uniqueDateMap := [:]
}