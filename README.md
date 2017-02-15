Request Log Analyzer
=====

## What, pray tell, is in the box?!?
![What's in the box?](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docs/whats-in-the-box.jpg)

Logstash. Logstash is what's in the box.

Using the `docker-compose.yml` you can spin up a set of Docker images to analyze NCSA-style request logs, and graph them with handy dashboards:

![Kibana dashboard](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docs/kibana-dashboard.png)

Results too fast? Not sure you're even reading any bytes? Here's a handy dashboard to check the response sizes:

![Kibana dashboard - bytecount](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docs/kibana-dashboard-bytes.png)

## Awesome, how do I use it?

You don't even need to get this repo to use it - only the [docker-compose.yml](docker-compose.yml) file. Want to build your own image and hack around? Grab the repo.

##### 1) Run it:

```bash
# This directory must include at least one file with request.log anywhere in the file name
# (IE: request.log, foo.request.log, request.log.20170101)
export LOG_DIR="/path/to/request/logs"
wget https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docker-compose.yml
docker-compose -f docker-compose.yml up -d
```

##### 2) Give Logstash some time to index your logs, then go <a href="http://localhost:5601/app/kibana#/dashboard/Load-Result-Dashboard?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-30d,mode:quick,to:now))&_a=(filters:!(),options:(darkTheme:!f),panels:!((col:1,id:Total-Sample-Calls,panelIndex:1,row:1,size_x:3,size_y:2,type:visualization),(col:1,id:Verb-Breakdown,panelIndex:2,row:6,size_x:3,size_y:2,type:visualization),(col:1,id:Response-Code-Breakdown,panelIndex:3,row:3,size_x:3,size_y:3,type:visualization),(col:4,id:'Response-Time-Histogram-(per-minute)',panelIndex:4,row:1,size_x:9,size_y:4,type:visualization),(col:4,id:Requests-Per-Second,panelIndex:5,row:5,size_x:9,size_y:3,type:visualization),(col:1,id:'Max-Response-Time-(per-minute)',panelIndex:6,row:8,size_x:4,size_y:3,type:visualization),(col:5,id:'Min-Response-Time-(per-minute)',panelIndex:7,row:8,size_x:4,size_y:3,type:visualization),(col:9,id:'Average-Response-Time-(per-minute),-with-Standard-Deviation',panelIndex:8,row:8,size_x:4,size_y:3,type:visualization)),query:(query_string:(analyze_wildcard:!t,query:'*')),title:'Load%20Result%20Dashboard',uiState:(P-2:(vis:(params:(sort:(columnIndex:!n,direction:!n)))),P-3:(vis:(params:(sort:(columnIndex:!n,direction:!n))))))">here</a>.

This will use a pre-configured dashboard for the past 30 days. If your data is older than 30 days, you can use the time picker in the upper right-hand corner of the dashboard:

![Kibana Timepicker](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docs/kibana-time-picker.png)

## How do I know when it's done? Or what it's doing?

This is what the [monitoring](http://localhost:5601/app/monitoring#/elasticsearch/indices) component does:

![Kibana Monitoring of Index](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/docs/monitoring-screen.png)

Select one of the indices that has the word "logstash" in it, and watch both the indexing rate and document count. If this rate drops to zero and stays there a while, it's probably done indexing your logs.

## When it's done running

Once running, you can find your services at:
 * [Monitoring at http://localhost:5601/app/monitoring](http://localhost:5601/app/monitoring)
 * [Kibana at http://localhost:5601/app/kibana](http://localhost:5601/app/kibana)

## What's it going to do?
It'll spin up a cluster that looks like:
 * 1 Elasticsearch master
 * 1 Elasticsearch slave (`node.master` set to false)
 * 1 Kibana node pointing at the ES master
 * 1 Logstash node pointing at the ES master

Once the cluster spins up, the Logstash node will use a pre-baked `logstash.conf` and Elasticsearch index template for your logs. The expected format is NCSA-request with an extra "latency" value at the end (IE: first byte to last byte). Any files in the specified `LOG_DIR` environment variable with the string `request.log` in it (prefix, suffix, wherever) will be indexed. That means `bob-request.log.12345` will be indexed, as will `request.log` or `request.log.12345`.

When you're done, you get a nice dashboard (pictured above), and the ability to gain insight out of your request logs.

## But why?

Maybe you're running load tests like the image above, and you want to know what's going on. Maybe you've got an app in a given environment and don't have metrics or telemetry. Maybe you're bored. No matter why, get your ops team (or whomever) to get you request logs, and you can now see what's going on.

Don't want to parse request logs? Want to configure Logstash in a different way? Grab the `docker-compose.config.yml` file, and run it like this:

```bash
# This directory must include at least one file with request.log anywhere in the file name
# (IE: request.log, foo.request.log, request.log.20170101)
export LOG_DIR="/path/to/request/logs"
export CONFIG_DIR="/path/to/logstash/conf"
docker-compose -f docker-compose.yml -f docker-compose.config.yml up -d
```

Maybe you have a fixed path, and want to know how many requests Customer X got instead of Customer Y. Maybe your request format is weird. Maybe you're a masochist. Who cares! Feel free to grab the [logstash.conf](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/app/logstash.conf) and [jetty-request-template.json](https://raw.githubusercontent.com/8x8Cloud/logstash-in-a-box/5.x/app/jetty-request-template.json) out of the `app` directory as a guide.

## Other things of interest

#### Cleanup

When you're done you're probably going to want to clean up the Docker volumes:

```bash
docker-compose down
docker volume ls -f dangling=true -q | xargs docker ...
```

*(Please note the above will destroy all dangling volumes, so make sure you mean to run it. Otherwise, you can delete them one at a time using `docker volume rm`. Ellipsis for your protection.)*

## What is this?
The Docker image itself is an Alpine Linux build based on `frolvlad/alpine-oraclejdk8:slim`, that then installs a copy of Logstash. Upon starting the image, it will attempt to restore a set of Kibana dashboards, index patterns, searches and visualizations  in the `kibana-goodies` directory. These were hand crafted objects exported using one of the dump scripts from the [Beats Dashboards](https://github.com/elastic/beats-dashboards) (see the `save` directory).

The Logstash install itself uses a config file that uses a `file` input, reading from `/input/**/*request.log*`, which is in turn bound via the volume statement mapping your `${LOG_DIR}` directory. So if you have your request logs in `/var/log/apache2`, you would set your `LOG_DIR` environment variable to `/var/log/apache2`, and in turn it would look for any file with the string `request.log` in it.

The rest of the Logstash configuration consists of parsing the NCSA-style request log, parsing the timestamp so that we index based on events within the log (rather than ingestion time), and eventually spitting the data into an ElasticSearch node at `http://elasticsearch-master:9200` (this comes from our `docker-compose.yml` file). An index mapping will be supplied so that fields aren't indexed, and that numerical values are parsed accordingly. You don't want to look for long response times only to find ElasticSearch has automatically classified your response time as a string.

#### Request log format

Please note that in order to render the dashboard, the visualizations make use of an extended request log. Each of our servlet containers adds an additional integer at the end of the request log, indicating how many milliseconds the request took from first byte to last byte. If you do not have this value in your logs they will still parse, but the dashboard will be unable to graph anything that is based on response time.

#### Enabling extended request logs

Enabling logging differs based on your container, the version of the container, and how you're using the container. Here are a couple of popular containers:

 * [Jetty](http://www.eclipse.org/jetty/documentation/9.3.x/configuring-jetty-request-logs.html) - enable logging latency.
 * [Tomcat](https://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging) - configure your logging valve.

Don't see your container? See a mistake? Submit a pull request!

## What now?
We're just starting. The first dashboards/visualizations were written to give us insight into our request logs from load tests, and various production environments. As more and more people use this image, we can start adding new dashboards, with all kinds of new insights.
