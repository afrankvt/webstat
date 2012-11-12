//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   12 Nov 2012  Andy Frank  Creation
//

**
** DateSpan models a date span.
**
@Js
const class DateSpan
{
  ** Make a date span to cover the full month of the given Date instance.
  new makeMonth(Date d)
  {
    this.start = d.firstOfMonth
    this.end   = d.lastOfMonth
  }

  ** Constructor.
  new make(Date start, Date end)
  {
    if (end < start) throw ArgErr("end < start")
    this.start = start
    this.end = end
  }

  ** Start of date span.
  const Date start

  ** End of date span.
  const Date end

  ** Return true if given date falls incluslvily into this span.
  Bool contains(Date d) { d >= start && d <= end }

  ** Return number of days in this date span.
  Int numDays() { (end - start).toDay }

  ** String representation.
  override Str toStr() { "${start}..${end}" }
}