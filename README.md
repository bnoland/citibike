Script to detect possible groups of riders in Citi Bike trip data.

Descriptions of grouping methods
--------------------------------

In the following descriptions, two times are considered "close" if they are
within some user-defined threshold of each other.

### Method 1

For each observation X, computes the group of observations Y such that X and Y
each have the same start and end stations, and the start and stop times of Y are
sufficiently "close" to those of X.

This method may generate duplicate groups. These are not present in the output.

### Method 2

Computes groups defined as follows: observations X and Y are in the same group
if and only if there exist observations X = X_1, X_2, ..., X_n = Y such that for
each 1 <= i < n, X_i and X_{i+1} have the same start and end stations, and the
start and stop times of X_i and X_{i+1} are sufficiently "close".

The data
--------

Data taken from:
https://s3.amazonaws.com/tripdata/index.html

For information about this data, see:
https://www.citibikenyc.com/system-data
