//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

using web

**
** BarPlot
**
@Js
internal class BarPlot
{
  new make(Obj:Int data)
  {
    this.data = data
  }

  Void write(WebOutStream out)
  {
    if (data.isEmpty)
    {
      out.p.i.w("No data").iEnd.pEnd
      return
    }

    keys := data.keys
    max  := data.vals.max.toFloat
    w := 32
    h := 100

    style := "style='float:left; width:${w}px; height:${h+48}px; position: relative; background:#f8f8f8; margin-right:2px;'"
    out.div("style='font-size:70%'")

    keys.each |k|
    {
      v := data[k]
      y := ((v.toFloat / max.toFloat) * h.toFloat).round.toInt
      d := v.toLocale
      if (v > 1000) d = (v.toFloat / 1000f).toLocale("#.0") + "k"

      out.div(style)
        .div("style='position:absolute; top:0; width:${w}px; text-align:center;'").esc(d).divEnd
        .div("style='position:absolute; top:${24+h-y}px; width:${w}px; height:${y}px; background:#ccc;' title='$v.toLocale'").divEnd
        .div("style='position:absolute; bottom:0; width:${w}px; text-align:center;'").esc(k.toStr).divEnd
        .divEnd
    }

    out.divEnd
    out.div("style='clear:both'").divEnd


    // keys.each |k|
    // {
    //   v := data[k]
    //   dy := ((v.toFloat / max.toFloat) * dh.toFloat).round.toInt
    //
    //   g.brush = Color("#788cab")
    //   if (dy <= 1) g.drawLine(dx, h-15, dx+dw-2, h-15)
    //   else g.fillRect(dx, h-14-dy, dw-1, dy)
    //
    //   tx := dx + ((dw - fv.width(v.toStr) - 1) / 2)
    //   g.font = fv
    //   g.drawText(v.toStr, tx, h-26-dy)
    //
    //   g.brush = Color.black
    //   g.font = fk
    //   tx = dx + ((dw - fk.width(k.toStr) -1) / 2)
    //   g.drawText(k.toStr, tx, h-12)
    //   dx += dw
    // }
  }

  private Obj:Int data
}