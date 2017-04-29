//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

**
** ReferrerProc processes referrers.
**
@Js
class ReferrerProc : LogProc
{
  ** It-block ctor.
  new make(|This| f)
  {
    f(this)

    baseDomain := ""
    wwwDomain  := ""

    if (domain.startsWith("www."))
    {
      baseDomain = domain["www.".size..-1]
      wwwDomain  = domain
    }
    else
    {
      baseDomain = domain
      wwwDomain  = "www.$domain"
    }

    this.self = [
      "http://$baseDomain",
      "https://$baseDomain",
      "http://$wwwDomain",
      "https://$wwwDomain"
    ]
  }

  ** Domain used for indentifying "self" referrers.
  const Str domain

  ** Referrer stats for this log.
  ReferrerStat[] stats() { map.vals }

  ** Search provider stats
  Str:Int search := [:]

  ** Search terms stats
  Str:Int searchTerms := [:]

  ** Socal network stats.
  Str:Int social := [:]

  ** Social referrer stats.
  ReferrerStat[] socialStats() { socialMap.vals }

  override Void process(LogEntry entry)
  {
    m := check(entry)
    if (m == null) return

    uri  := entry["cs(Referer)"].val
    ref  := m[uri] ?: ReferrerStat { it.uri=uri }
    last := entry.ts.toTimeZone(ny)

    ref.count++
    ref.last = last
    m[uri] = ref
  }

  ** Check referrer and return the appropriate working map, or null
  ** if this is not a valid referrer and should be ignored.
  private [Str:ReferrerStat]? check(LogEntry e)
  {
    ref := e["cs(Referer)"]
    if (ref == null) return null
    if (self.any |s| { ref.val.startsWith(s) }) return null

    uri := ref.val
    http  := uri.startsWith("http://")
    https := !http && uri.startsWith("https://")

    // skip but include if not proper uri
    if (!http && !https) return map

    // find host
    off  := uri.index("/", http ? 7 : 8) ?: -1
    host := uri[(http ? 7 : 8)..<off].split('.')
    if (host.size < 2) return map
    fullhost := host.join(".")

    // white-list providers
    if (host.contains("google")) { addTerm("google", "q", uri); return null }
    if (host.contains("bing"))   { addTerm("bing",   "q", uri); return null }
    if (host.contains("yahoo"))  { addTerm("yahoo",  "p", uri); return null }
    if (host.contains("aol"))    { addTerm("aol",    "q", uri); return null }
    if (host.contains("yandex")) { addTerm("yandex", "text", uri); return null }

    // social networks
    if (fullhost == "t.co")        { addSocial("twitter",  uri); return socialMap }
    if (fullhost == "fb.me")       { addSocial("facebook", uri); return socialMap }
    if (host.contains("facebook")) { addSocial("facebook", uri); return socialMap }

    // otherwise normal referrer
    return map
  }

  private Void addTerm(Str provider, Str q, Str uri)
  {
    // update provider
    search[provider] = (search[provider] ?: 0) + 1

    // update terms
    v := Uri.fromStr(uri).query[q]
    if (v == "") return
    if (v != null)
    {
      // decode value
      try
      {
        v = Uri.decodeQuery(v).keys.first
        searchTerms[v] = (searchTerms[v] ?: 0) + 1
      }
      catch {} // ignore?
    }
  }

  private Void addSocial(Str network, Str uri)
  {
    // update network
    social[network] = (social[network] ?: 0) + 1
  }

  private const Str[] self
  private const TimeZone utc := TimeZone.utc
  private const TimeZone ny  := TimeZone("New_York")
  private Str:ReferrerStat map := [:]
  private Str:ReferrerStat socialMap := [:]
}

**************************************************************************
** ReferrerStat
**************************************************************************
@Js
class ReferrerStat
{
  Str uri   := ""
  Int count := 0
  DateTime last := DateTime.defVal
}