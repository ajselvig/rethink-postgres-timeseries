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

These are the result from my machine (late 2013 MacBook Pro with 2.3 GHz Intel Core i7 and solid state drive).
I'm using PostgresQL 9.4 and RethinkDB 1.15.

```
## RethinkDB Benchmark ##
                                     user     system      total        real
Create table and index:          0.000000   0.000000   0.000000 (  2.992940)
Populate 500000 initial pings:  58.380000  18.680000  77.060000 (389.569893)
Insert single ping:              0.000000   0.000000   0.000000 (  0.003109)
Get pings by key:                0.630000   0.040000   0.670000 (  1.527739)
Get pings by time range:         0.130000   0.010000   0.140000 (  0.356579)

## PostgresQL Benchmark ##
                                     user     system      total        real
Create table and index:          0.000000   0.000000   0.000000 (  0.246710)
Populate 500000 initial pings:   8.030000   4.300000  12.330000 ( 91.593710)
Insert single ping:              0.000000   0.000000   0.000000 (  0.000258)
Get pings by key:                0.040000   0.000000   0.040000 (  0.149622)
Get pings by time range:         0.010000   0.000000   0.010000 (  0.029836)

```