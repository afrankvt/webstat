# webLogView

A native [Fantom](http://fantom.org) web log parser/analyzer/viewer for W3C
extended log file format weblogs.  This is particularly designed to be used
with the logs produced by [Wisp](http://fantom.org/doc/wisp/index.html), but
should work with any validly formatted log.

This is very much a work in progress, and is quite simple at the moment.  It's
also a very low priority project - so don't expect updates often ;)

## Usage:

    $ fan webLogView
    webLogView 1.0
    usage: fan webLogView <domain> <logfile> [outputHtml]
      domain:      Domain name of website
      logfile:     W3C extended log file format log file
      outputHtml:  File to output HTML, or stdout if not given

## License

All code licensed under MIT License.