# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HdfHelper.t'


use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('HdfHelper') };

#########################

my @array = (0,1,2,3,4,5,6,7,8,9);
my $slice = HdfHelper::get_every_nth(\@array, 2, 0);
my $expected = [0,2,4,6,8];
is_deeply($slice, $expected, "get_every_nth");
