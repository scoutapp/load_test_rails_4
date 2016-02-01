# Rails 4 Load Testing App

This is an application used by the [Scout](https://scoutapp.com) enginneering team to benchmark the performance of our application monitoring agent. 

## Branch structure

Different benchmarks and their associated agents are configured via Git branches. Basic structure:

* master - No app monitoring agent installed. The baseline for the representative test.
* many_queries/fast_endpoint/etc - No app monitoring installed. The name identifies the test.
* [scout|newrelic|skylight]_BENCHMARK - a benchmarking test for the specific app monitoring agent.

## Running and analyzing test

1. Delete the existing `production.log` file. All tests should run in the production environment.
2. Start the app: `unicorn -c config/unicorn.rb`
3. Fetch a list of endpoints to benchmark: `wget http://[IP]/users/urls -O urls.txt`
4. From an other server, run siege: `siege -v -f urls.txt -c 30 -b -t 10M`
5. Gracefully shutdown the unicorn workers: `ps aux | grep unicorn`, find the master, then `kill -QUIT PID`.
6. Save the log file w/the branch name (ie: `mv log/production.log log/production.scout.log`).
7. Inspect Stackprof output saved in `tmp/stackprof_[BRANCH]`.

## Monitoring and Profiling

The Scout StatsD Rack gem and Stackprofiler are included for monitoring and profiling. StatsD metrics are reported to localhost.

## APM Agent Configuration

All authentication is configured via environment variables:

* Scout - SCOUT_KEY
* New Relic - NEW_RELIC_LICENSE_KEY 
* Skylight - SKYLIGHT_AUTHENTICATION