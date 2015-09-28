+++
title = "Overview of the Spark Kernel Client Library"
date = "2015-07-29"
redirect = "http://www.spark.tc/overview-of-the-spark-kernel-client-library/"
tags = [ "apache spark", "open source" ]
categories = [ "ibm" ]
+++

In this third and final part of the Spark Kernel series (part 1, part 2), we
will focus on the client library, a Scala-based library used to interface with
the Spark Kernel. This library enables Scala applications to quickly
communicate with a Spark Kernel without needing to understand ZeroMQ or the
IPython message protocol. Furthermore, using the client library, Scala
applications are able to treat the Spark Kernel as a remote service, meaning
that they can run separately from a Spark cluster and use the kernel as a
remote connection into the cluster.

