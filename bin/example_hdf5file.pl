#!/usr/bin/env perl
use strict;
use warnings;
use Hdf5::File;
use Data::Dumper;
use Carp;
use English qw(-no_match_vars);

my $file = Hdf5::File->new();
$file->open(q[./random.hdf5]);

dump_groups(q[/]);


sub dump_attributes_group {
  my ($path) = @_;

  my @attributes = $file->get_group_attributes($path);

  for (my $n=0; $n<=$#attributes; $n++) {
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

  for(my $n=0; $n<=$#attributes; $n++) {
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

  my @datasets = $file->get_datasets($path);

  for (my $n=0; $n<=$#datasets; $n++) {
    printf "dataset  : %s %s\n", $path , $datasets[$n] or croak qq[Error printing: $ERRNO];
    dump_attributes_dataset($path .$datasets[$n]);
    print Dumper($file->read_dataset($path . $datasets[$n], -1, -1)) or croak qq[Error printing: $ERRNO];
  }

  return 1;
}

sub dump_groups {
  my ($path) = @_;

  printf "group    : %s\n" , $path or croak qq[Error printing: $ERRNO];
  dump_attributes_group($path);
  dump_datasets($path);

  my @groups = $file->get_groups($path);

  for (my $n=0; $n<=$#groups; $n++) {
    if(!$groups[$n]) {
      next;
    }

    dump_groups(sprintf q[%s%s/], $path, $groups[$n]);
  }

  return 1;
}
