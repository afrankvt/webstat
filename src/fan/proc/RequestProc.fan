//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

**
** RequestProc processes requesets.
**
@Js
class RequestProc : LogProc
{
  ** It-block ctor.
  new make(|This| f)
  {
    f(this)
    dates.numDays.times |i| { pagesByDate[dates.start + Duration(i*1day.ticks)] = 0 }
    24.times |t| { pagesByTime[Time(t,0,0)] = 0 }
    Weekday.vals.each |w| { pagesByWeekday[w] = 0 }
  }

  ** DateSpan this proc covers.
  const DateSpan dates

  ** Total requests.
  Int total := 0

  ** Number of pages requested.
  Int pages := 0

  ** Number of images requested.
  Int images := 0

  ** Number of style sheets requested.
  Int styles := 0

  ** Number of scripts requested.
  Int scripts := 0

  ** Number of requests per Status Code
  Int:Int byStatus := [:]

  ** Average time taken for all requests in ms.
  Int avgTime := 0

  ** Min time taken for a request in ms.
  Int minTime := 0

  ** Max time take for a request in ms.
  Int maxTime := 0

  ** Page views by date
  Date:Int pagesByDate := Date:Int[:] { ordered=true }

  ** Page views by time of day.
  Time:Int pagesByTime := Time:Int[:] { ordered=true }

  ** Page vies by weekday.
  Weekday:Int pagesByWeekday := Weekday:Int[:] { ordered=true }

  ** Get pages breakout.
  Str:Int pagesByReq := [:]

  ** Get sections breakout.
  Str:Int pagesBySection := [:]

  override Void process(LogEntry entry)
  {
    sc := entry["sc-status"]?.val?.toInt
    if (sc == null) return

    // update overall metrics
    total++
    byStatus[sc] = (byStatus[sc] ?: 0) + 1

    // update time metrics
    if (entry.has("time-taken"))
    {
      time := entry["time-taken"].val.toInt
      sumTime += time
      avgTime = (sumTime.toFloat / total.toFloat).round.toInt
      minTime = minTime.min(time)
      maxTime = maxTime.max(time)
    }

    // breakout keys
    ts   := entry.ts
    dkey := ts.date;
    tkey := Time(ts.time.hour,0,0);
    wkey := ts.date.weekday;

    // type breakouts
    if (Util.isPage(entry))
    {
      // only count 200 for pages
      //if (sc != 200) return
      pages++
      pagesByDate[dkey] = pagesByDate[dkey] + 1
      pagesByTime[tkey] = pagesByTime[tkey] + 1
      pagesByWeekday[wkey] = pagesByWeekday[wkey] + 1

      // req/section breakouts
      uri := entry["cs-uri-stem"]?.val
      pagesByReq[uri] = (pagesByReq[uri] ?: 0) + 1
      base := (uri.size == 1) ? "/" : uri[0..((uri.index("/",2) ?: 0)-1)]
      pagesBySection[base] = (pagesBySection[base] ?: 0) + 1
    }
    else
    {
      stem := entry["cs-uri-stem"]?.val
      if (stem == null) return
      else if (stem.endsWith(".png")) { images++ }
      else if (stem.endsWith(".jpg")) { images++ }
      else if (stem.endsWith(".gif")) { images++ }
      else if (stem.endsWith(".css")) { styles++ }
      else if (stem.endsWith(".js"))  { scripts++ }
    }
  }

  private Int sumTime := 0
}
