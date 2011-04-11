ffi-libarchive
==============

An ffi binding to libarchive.

This library provides ruby-bindings to the well-known
[libarchive](http://code.google.com/p/libarchive/) library. It should be interface-compatible to libarchive-ruby and libarchive-ruby-swig gems.

Why another binding? Because I often work on workstations without
development libraries of libarchive installed. An FFI-based gem allows
to use the library without the hassle of compiling native extensions.

Note that this is not completely true for this library. Two methods,
``Entry::copy_stat`` and ``Entry::copy_lstat`` require a small native
extension through ``ffi-inliner``, though this does not require
development files of libarchive but only of libc.

Features
--------

* Compatible interface to libarchive-ruby Entry::copy_lstat and
* Entry::copy_stat require ffi-inliner because of the platform
  dependence of stat() and lstat() functions of libc

Examples
--------

require 'ffi-libarchive'

Requirements
------------

* ``ffi`` >= 1.0.0
* ``ffi-inliner`` for ``Entry::copy_lstat`` and ``Entry::copy_stat``

Install
-------

* gem install ffi-libarchive

Author
------

Original author: Frank Fischer

License
-------

(The MIT License)

Copyright (c) 2011 Frank Fischer

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
