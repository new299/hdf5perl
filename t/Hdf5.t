# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Hdf5.t'

#########################


use strict;
use warnings;
use Hdf5;

use Test::More tests => 1;
BEGIN { use_ok('Hdf5') };

#########################

