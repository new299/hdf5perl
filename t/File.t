# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        cwright
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Hdf5.t'

use strict;
use warnings;
use Test::More tests => 10;

our $PKG = 'Hdf5::File';

use_ok($PKG);

{
  my $hf = $PKG->new();
  isa_ok($hf, $PKG);
  ok(!$hf->is_open, 'file is not open yet');
}

{
  my $hf = $PKG->new();
  $hf->open('t/data/test.hdf5');

  ok($hf->is_open, 'file is open');
}

{
  my $hf = $PKG->new();
  $hf->open('t/data/nonexistent.hdf5');
  ok(!$hf->is_open, 'file is not open');
}

{
  my $hf = $PKG->new('t/data/test.hdf5');
  isa_ok($hf, $PKG);

  ok($hf->is_open, 'file is open with constructor');
}

{
  my $hf = $PKG->new('t/data/test.hdf5');

 SKIP: {
    skip "all either broken or unchecked", 1;
    is_deeply([$hf->get_groups(q[/])], [qw(IntermediateData Meta Raw Sequences)], 'get_groups');
  }
}

{
  my $hf = $PKG->new('t/data/test.hdf5');

 SKIP: {
    skip "all either broken or unchecked", 1;
    is_deeply([$hf->get_datasets(q[/Meta/User])], [qw(Edge Seal Wave)], 'get_groups');
  }
}

{
  my $hf    = Hdf5::File->new('t/data/test.hdf5');
  my $start = 0;
  my $end   = 5;
  my %data  = $hf->read_dataset("/IntermediateData/Channel_1/Events", $start, $end);

  my $result   = $data{start};
  my $expected = [0,1,2,4,6];

  is_deeply($result, $expected, 'get compound dataset');
}
