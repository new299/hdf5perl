#!/usr/bin/env perl
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
use Hdf5::File;
use Data::Dumper;
use Carp;
use English qw(-no_match_vars);
use Readonly;

our $VERSION = '0.01';

my $fn = shift @ARGV;
$fn   ||= q[t/data/14521.hdf5];

my $file = Hdf5::File->new($fn);

dump_groups(q[/]);

sub dump_attributes_group {
  my ($path) = @_;

  my @attributes = $file->get_group_attributes($path);

  for my $n (0..scalar @attributes-1) {
    if(!$attributes[$n]) {
      next;
    }

    printf "attribute: %s %s\n", $path, $attributes[$n] or croak qq[Error printing: $ERRNO];
    print Dumper($file->read_attribute($path, $attributes[$n])) or croak qq[Error printing: $ERRNO];
  }

  return 1;
}

sub dump_attributes_dataset {
  my ($path) = @_;

  my @attributes = $file->get_dataset_attributes($path);

  for my $n (0..scalar @attributes-1) {
    if(!$attributes[$n]) {
      next;
    }

    printf "attribute: %s %s\n", $path , $attributes[$n] or croak qq[Error printing: $ERRNO];
    print Dumper($file->read_attribute($path . $attributes[$n])) or croak qq[Error printing: $ERRNO];
  }

  return 1;
}

sub dump_datasets {
  my ($path) = @_;

  Readonly::Scalar my $READ_ALL => -1;

  my @datasets = $file->get_datasets($path);

  for my $n (0..scalar @datasets-1) {
    printf "dataset  : %s %s\n", $path , $datasets[$n] or croak qq[Error printing: $ERRNO];
    dump_attributes_dataset($path .$datasets[$n]);
    print Dumper($file->read_dataset($path . $datasets[$n], $READ_ALL, $READ_ALL)) or croak qq[Error printing: $ERRNO];
  }

  return 1;
}

sub dump_groups {
  my ($path) = @_;

  printf "group    : %s\n" , $path or croak qq[Error printing: $ERRNO];
  dump_attributes_group($path);
  dump_datasets($path);

  my @groups = $file->get_groups($path);

  for my $n (0..scalar @groups-1) {
    if(!$groups[$n]) {
      next;
    }

    dump_groups(sprintf q[%s%s/], $path, $groups[$n]);
  }

  return 1;
}
