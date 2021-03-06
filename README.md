# Rails 4 Load Testing App

This is an application used by the [Scout](https://scoutapp.com) team to benchmark the performance of our application monitoring agent. 

## Branch structure

Different benchmarks and their associated agents are configured via Git branches. Basic structure:

* master - No app monitoring agent installed. The baseline for the representative test.
* many_queries/fast_endpoint/etc - No app monitoring installed. The name identifies the test.
* [scout|newrelic]_BENCHMARK - a benchmarking test for the specific app monitoring agent.

## Running and analyzing test

1. Start 3 SSH sessions:
  * app server w/rails
  * app server w/rails app
  * util server where siege will be ran
2. App (window 1): `cd /vagrant/rails_4/`
3. App (window 1): Clear out past results and start the app: `rake bench:prep`.
4. Util: Fetch a list of endpoints to benchmark: `wget http://[IP]:8080/users/urls -O urls.txt`
5. Util: Warmup the app cache: `siege -v -f urls.txt -c 30 -b -t 1M`
6. App (window 2): Clear out the log file during the warmup: `rake data:clear`
7. Util: Seige: `siege -v -f urls.txt -c 30 -b -t 10M`
8. App (window 2): When siege completes, gracefully shutdown the unicorn workers: `rake unicorn:stop`
9. App: (window 2): Inspect the log results: `rake data:log`

## Running tests against the `fast_endpoint` branch

A different set of URLs needs to be used to for this test:

Util: `wget http://[IP]/fast/urls -O fast.txt`

Use the `fast.txt` file vs. `urls.txt` with siege:

`siege -v -f fast.txt -c 30 -b -t 10M`

## Monitoring and Profiling

StatsD metrics are reported to localhost so results can be previewed during a test run.

## Enabling Stackprof

Stackprof is disabled by default so it doesn't influence test results. To enable:

`prof=true rake bench:prep`

You should see the following via `STDOUT`: `Stackprof enabled.`

To view results from the test run:

`rake data:stackprof`

## APM Agent Configuration

All authentication is configured via environment variables:

* Scout - SCOUT_KEY
* New Relic - NEW_RELIC_LICENSE_KEY 

## Bootstrapping

1. `bundle`
2. `RAILS_ENV=production rake db:create db:migrate db:seed`
