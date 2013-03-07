# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        cwright
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
use strict;
use warnings;
use Hdf5;

use Test::More tests => 5;
BEGIN { use_ok('Hdf5') };

{
  my $in    = [0,1,2,3,4,5,6,7,8,9];
  my $slice = Hdf5::get_every_nth($in, 2, 0);
  is_deeply($slice, [0,2,4,6,8], "get_every_nth");
}

{
  my $in = [0,1,2,3,4,5,6,7,8,9];
  Hdf5::rescale_array($in, 0.0, 1.0);
  is_deeply($in, [0,1,2,3,4,5,6,7,8,9], "rescale: do nothing");
}

{
  my $in = [0,1,2,3,4,5,6,7,8,9];
  Hdf5::rescale_array($in, 0.0, 2.0);
  is_deeply($in, [0,2,4,6,8,10,12,14,16,18], "rescale: double");
}

{
  my $in = [0,2,4,6,8,10,12,14,16,18];
  Hdf5::rescale_array($in, 1.0, 1.0);
  is_deeply($in, [1,3,5,7,9,11,13,15,17,19], "rescale: add one");
}
