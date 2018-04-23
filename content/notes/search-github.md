+++
tags = ["utility"]
date = "2017-03-13T20:51:09-05:00"
category = ["snippet"]
title = "Search Github"
slug = "search-github"
+++

Couple of notes about searching on Github that have proven to be quite useful:

1. You can include/exclude specific files using the `filename` property in a
   search.

      The following searches for content _"some content"_ only in `.config` files.

      ```
      some content filename:.config
      ```

      The following searches for content _"some content"_ in all files but
      `.config` files.

      ```
      some content -filename:.config
      ```

2. You can include/exclude specific users and organizations in a search. This
   is handy when I'm trying to judge how much use a library of mine is getting
   in the open source community while avoiding my own projects.

      The following excludes matches in the specified users/organizations.

      ```
      scala-debugger -user:ensime -user:chipsenkbeil
      ```

