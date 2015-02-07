//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   27 Jun 2014  Andy Frank  Creation
//

using web

**
** SummaryRenderer renders summary stats.
**
@Js
class SummaryRenderer
{
  ** Construct new PageRenderer for HtmlRenderer.
  new make(LogProc[] p)
  {
    this.procs = p
  }

  ** Write content.
  Void write(WebOutStream out)
  {
    Int days := procs.first->dates->numDays
    RequestProc rp   := procs.find |p| { p is RequestProc }
    VisitorProc vp   := procs.find |p| { p is VisitorProc }
    UserAgentProc up := procs.find |p| { p is UserAgentProc }

    // TODO FIXIT: pull out into head callback
    out.style.w(
     "#summary + div > table { border-collapse: collapse; }
      #summary + div > table td { padding: 2px 6px 2px 2em; border: 1px solid #ccc; }
      #summary + div > table td:nth-child(2) { text-align:right; }
      #summary + div > table td:nth-child(3) { text-align:right; }
      #summary + div > table td[colspan] { padding-left: 6px; font-weight: bold; background:#f8f8f8; }
      ").styleEnd

    out.h2("id='summary'").w("Summary").h2End
    out.div("class='section'")
    out.table

    // requests
    out.tr.td("colspan='3'").w("Requests").tdEnd.trEnd
    ["pages", "images", "styles", "scripts", "total"].each |n|
    {
      Int v := rp.trap(n)
      out.tr
        .td.w(n=="styles" ? "Stylesheets" : n.capitalize).tdEnd
        .td.w(v.toLocale).tdEnd
        .td.w((v.toFloat / days.toFloat).round.toInt.toLocale).w("/day").tdEnd
        .trEnd
    }

    // visitors
    out.tr.td("colspan='3'").w("Visitors").tdEnd.trEnd
    ["total", "uniques", "unknown"].each |n|
    {
      Int v := vp.trap(n)
      out.tr
        .td.w(n.capitalize).tdEnd
        .td.w(v.toLocale).tdEnd
        .td
          if (n == "total") out.w((v.toFloat / days.toFloat).round.toInt.toLocale).w("/day")
          out.tdEnd
        .trEnd
    }

    // user-agents
    ut := up.mobile + up.desktop + up.unknown
    mp := (up.mobile.toFloat  / ut.toFloat * 100f).toLocale("0.00")
    dp := (up.desktop.toFloat / ut.toFloat * 100f).toLocale("0.00")
    kp := (up.unknown.toFloat / ut.toFloat * 100f).toLocale("0.00")
    out.tr.td("colspan='3'").w("User Agents").tdEnd.trEnd
    out.tr.td.w("Mobile") .tdEnd.td.w(up.mobile.toLocale).tdEnd.td.w("${mp}%").tdEnd.trEnd
    out.tr.td.w("Desktop").tdEnd.td.w(up.desktop.toLocale).tdEnd.td.w("${dp}%").tdEnd.trEnd
    out.tr.td.w("Unknown").tdEnd.td.w(up.unknown.toLocale).tdEnd.td.w("${kp}%").tdEnd.trEnd

    out.tableEnd
    out.divEnd
  }

  private LogProc[] procs
}
