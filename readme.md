# webstat

A native [Fantom](http://fantom.org) web log parser/analyzer/viewer for W3C
extended log file format weblogs.  This is particularly designed to be used
with the logs produced by [Wisp](http://fantom.org/doc/wisp/index.html), but
should work with any validly formatted log.

This is very much a work in progress, and is quite simple at the moment.  It's
also a very low priority project - so don't expect updates often ;)

## Usage:

    $ fan webstat

    Usage:
      webStats [options] <logFile>
    Arguments:
      logFile    W3C extended log file format log file to analyze
    Options:
      -help, -?         Print usage help
      -month <Str>      Month to process (defaults to current month)
      -domain <Str>     Domain name of website
      -outDir <File>    Write HTML output to directory (defaults to stdout)
      -unique <Str>     Cookie name to use for comparing unique users (default uses IP)

## License

All code licensed under MIT License.
