//
// Copyright (c) 2012, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Oct 2012  Andy Frank  Creation
//

// Some test data here (Apache 2):
// http://code.google.com/p/browserscope/source/browse/trunk/test/user_agent_data.csv

**
** UserAgent parses and models a browser's user-agent string.
**
@Js
const class UserAgent
{
  ** Parse UserAgent from string value.
  static new fromStr(Str s)
  {
    s = s.trim
    start := 0
    size  := s.size
    prod  := UaProduct[,]
    comm  := Str[,]

    space  := ' '
    rparen := '('
    lparen := ')'

    while (start < size)
    {
      // eat leading whitespace
      while (start<size && s[start] == ' ') start++
      if (start>=size) break
      end := start

      // next token
      if (s[start] == rparen)
      {
        // comment
        while (end<size-1 && s[end+1] != lparen) end++
        val := s[start+1..end]
        comm.addAll(val.split(';'))
        end++
      }
      else
      {
        // product
        while (end<size-1 && s[end+1] != space) end++
        vals := s[start..end].split('/')
        name := vals.getSafe(0, "")
        ver  := vals.getSafe(1, "")
        prod.add(UaProduct { it.name=name; it.ver=ver })
      }

      start = end + 1
    }

    return UserAgent { products=prod.toImmutable; comments=comm.toImmutable }
  }

  private new make(|This|? b) { if (b != null) b(this) }

  ** Products
  const UaProduct[] products := UaProduct[,]

  ** Comments
  const Str[] comments := Str[,]
}

**
** UaProduct
**
@Js
const class UaProduct
{
  internal new make(|This|? b) { if (b != null) b(this) }

  ** Product name
  const Str? name := null

  ** Product version number
  const Str? ver := null

  override Str toStr() { "$name/$ver" }
}

