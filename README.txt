= forkify

* http://github.com/dakrone/forkify

== DESCRIPTION:

  forkify.rb makes it easy to process a bunch of data using 'n'
  worker processes. It is based off of forkoff and threadify by Ara Howard.
  It aims to be safe to use on Ruby 1.8.6+ and Ruby 1.9.1+

== FEATURES/PROBLEMS:

* forkify is _extremely_ beta quality currently.
* NOTE: Hash forkifing returns a 2-dimensional array.
* Spawn processes easily!

== SYNOPSIS:

  enumerable = %w( a b c d )
  enumerable.forkify(2) { 'process this block using two worker processes' }
  enumerable.forkify    { 'process this block using the default of 5 processes' }

== REQUIREMENTS:

* Testy - only for running the tests

== INSTALL:

* sudo gem install forkify

== LICENSE:

(The MIT License)

Copyright (c) 2009 Lee Hinman

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
