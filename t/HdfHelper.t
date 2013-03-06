use strict;
use warnings;
use Hdf5;

use Test::More tests => 5;
BEGIN { use_ok('Hdf5') };


my @array = (0,1,2,3,4,5,6,7,8,9);
my $slice = Hdf5::get_every_nth(\@array, 2, 0);
my $expected = [0,2,4,6,8];
is_deeply($slice, $expected, "get_every_nth");

$expected = [0,1,2,3,4,5,6,7,8,9];
Hdf5::rescale_array(\@array, 0.0, 1.0);
is_deeply(\@array, $expected, "rescale: do nothing");

$expected = [0,2,4,6,8,10,12,14,16,18];
Hdf5::rescale_array(\@array, 0.0, 2.0);
is_deeply(\@array, $expected, "rescale: double");

$expected = [1,3,5,7,9,11,13,15,17,19];
Hdf5::rescale_array(\@array, 1.0, 1.0);
is_deeply(\@array, $expected, "rescale: add one");


