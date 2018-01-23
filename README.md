Experimental AWS deployer
============================

This is merely a playground. Unfinished, imperfect, sloppy code. For educational purpose only.

It gets aws credentials and create a t2.micro instance with an image of wordpress from Bitnami (while recommended vm size is actually m3.medium), using ruby aws-sdk.

Install
--------

Get the code and

    bundle install

Then launch it

    rackup

or in dev with a reload at each code change

    shotgun


So what now?
-------------

Various improvements could be done:

- write some damn tests
- add a timer on operations
- add a way to display admin password directly, as the bitnami method requires to log in aws console (but it's quite well described in the wordpress template click on bottom right)
- get this working with vue.js or react rather than just jQuery
- show more metadata information about the created VM
- display some random cat pictures slideshow while it's initializing, so the user can get some love
- keep an audit log of operations
- persist user creds somehow


Copyright
-------------
Copyright (c) mose  
Released under MIT license
