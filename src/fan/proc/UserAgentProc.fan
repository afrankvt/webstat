//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   30 Jun 2014  Andy Frank  Creation
//

**
** UserAgentProc processes user agent information.
**
@Js
class UserAgentProc : LogProc
{
  ** It-block ctor.
  new make(|This| f)
  {
    f(this)
    sets["Firefox"] = UserAgentSet { name="Firefox" }
    sets["Android"] = UserAgentSet { name="Android" }
    sets["Chrome"]  = UserAgentSet { name="Chrome" }
    sets["Safari"]  = UserAgentSet { name="Safari" }
    sets["Opera"]   = UserAgentSet { name="Opera" }
    sets["IE"]      = UserAgentSet { name="IE" }
    sets["Mobile Safari"] = UserAgentSet { name="Mobile Safari" }
    sets["Other"]   = UserAgentSet { name="Other" }
  }

  ** User agent sets fort his log.
  Str:UserAgentSet sets := [:]

  ** Number of mobile requests.
  Int mobile := 0

  ** Number of desktop requests.
  Int desktop := 0

  ** Number of unknown requests.
  Int unknown := 0

  override Void process(LogEntry entry)
  {
    fv := entry["cs(User-Agent)"]
    if (fv == null) return

    // parse ua
    ua := UserAgent(fv.val)

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

    // check for "invalid" iOS
    comment = ua.comments.find |c|
    {
      if (c == "iPhone") { count("Mobile Safari", "Unknown"); return true }
      if (c == "iPad")   { count("Mobile Safari", "Unknown"); return true }
      if (c == "iPod")   { count("Mobile Safari", "Unknown"); return true }
      return false
    }

    // other
    if (product == null && comment == null)
    {
      key := entry["cs(User-Agent)"].val
      // debug[key] = (debug[key] ?: 0) + 1
      count("Other", "")
    }
  }

  private Void count(Str name, Str ver)
  {
    // set count
    a := sets[name]
    a.num++

    // mobile/desktop
    switch (name)
    {
      case "Android":
      case "Mobile Safari": mobile++
      case "Other":         unknown++
      default:              desktop++
    }

    // ver count
    v := a.ver[ver]
    if (v == null)
    {
      v = UserAgentInfo { it.name=name; it.ver=ver }
      a.ver[ver] = v
    }
    v.num++
  }
}

**************************************************************************
** UserAgentSet
**************************************************************************
@Js
class UserAgentSet
{
  Str name := ""
  Int num  := 0
  Str:UserAgentInfo ver := Str:UserAgentInfo[:]
}

**************************************************************************
** UserAgentInfo
**************************************************************************
@Js
class UserAgentInfo
{
  Str name := ""
  Str ver  := ""
  Int num  := 0
}