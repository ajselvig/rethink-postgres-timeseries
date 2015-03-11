# RethinkDB vs PostgresQL Time Series Benchmarks

This repo contains some simple benchmarks comparing the performance of
RethinkDB and PostgresQL with modest sized time series data sets.

The data model used for testing is one table (pings) consisting of the following fields:
* time: a timestamp
* key_field: a string field with a set of possible values
* value_field: a random double

For each database, the following operations are performed:
1. A database and single table are created, along with an index on key_field
1. A large number of pings are populated in the table
1. A single new ping is inserted
1. All pings with one value of key_field are selected


## Results

```
## RethinkDB Benchmark ##
                                     user     system      total        real
Create table and index:          0.000000   0.010000   0.010000 (  2.617056)
Populate 50000 initial pings:    4.940000   1.400000   6.340000 ( 15.957680)
Insert single ping:              0.000000   0.000000   0.000000 (  0.425225)
Get pings by key:                0.040000   0.010000   0.050000 (  0.114125)

## PostgresQL Benchmark ##
                                     user     system      total        real
Create table and index:          0.000000   0.000000   0.000000 (  0.246849)
Populate 50000 initial pings:    0.720000   0.400000   1.120000 (  8.627506)
Insert single ping:              0.000000   0.000000   0.000000 (  0.000250)
Get pings by key:                0.000000   0.000000   0.000000 (  0.014032)

```