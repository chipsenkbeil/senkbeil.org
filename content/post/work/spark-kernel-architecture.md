+++
title = "Spark Kernel Architecture"
date = "2015-07-22"
redirect = "http://www.spark.tc/spark-kernel-architecture/"
tags = [ "apache", "spark", "open source" ]
categories = [ "ibm" ]
+++

In the first part of the Spark Kernel series, we stepped through the problem
with enabling interactive applications against Apache Spark and how the Spark
Kernel solved this problem. This week, we will focus on the Spark Kernel’s
architecture: how we achieve fault tolerance and scalability using Akka, why
we chose ZeroMQ with the IPython/Jupyter message protocol, what the layers of
functionality are in the kernel (see figure 1 below), and elaborate on an
interactive API from IPython called the Comm API.

