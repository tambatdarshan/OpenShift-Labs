# Installation

## Install openjdk 1.8

~~~bash

$ yum install openjdk-1.8

~~~

## Download Jmeter Binary

~~~bash

$ cd ~/Downloads
$ wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.5.tgz

$ mkdir /usr/local/jmeter
$ cp ~/Downloads/apache-jmeter-5.5.tgz /usr/local/jmeter
$ tar xvf /usr/local/jmeter/apache-jmeter-5.5.tgz
~~~

## Configure Environment Variables

~~~bash
$ tail -n 2 ~/.bashrc
export JMETER_HOME=/usr/local/jmeter/apache-jmeter-5.5
export PATH=${JMETER_HOME}/bin:$PATH
~~~

## Run Some Test

* We firstly add `http request sampler` under `Threads Groups`

![add_http_request](../images/add_http_request.png)

* Then we add `aggregate report` under `HTTP Request`

![add_aggregate_report](../images/add_aggregate_report.png)

* Specify the `threads count` and HTTP URL that we'd like to test

![test_threads_count](../images/test_threads_count.png)

![configure_http_URL](../images/configure_http_URL.png)

* Run the test and check the result

![check_report](../images/check_report.png)
