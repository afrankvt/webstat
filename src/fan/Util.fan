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
  ** Attempt to convert string value into Date instance.  If Date
  ** cannot be converted, returns null.
  static Date? toDate(Str? val)
  {
    if (val == null) return null
    return Date.fromLocale(val, "YYYY-MM-DD", false) ?:
           Date.fromLocale(val, "DD-MM-YYYY", false)
  }
}