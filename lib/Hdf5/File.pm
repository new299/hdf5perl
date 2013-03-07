# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        cwright
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package Hdf5::File;
use strict;
use warnings;
use Hdf5;
use Readonly;

our $VERSION = '0.01';

Readonly::Scalar my $START_ALL => -1;

sub new {
  my ($class, $filename) = @_;
  my $self = {};

  bless $self, $class;

  if($filename) {
    $self->open($filename);
  }

  return $self;
}

# Open the Hdf5 file
sub open { ## no critic (Homonym)
  my ($self, $filename) = @_;

  $self->{_filename}   = $filename;
  $self->{_filehandle} = Hdf5::H5Fopen($self->{_filename}, $Hdf5::H5F_ACC_RDONLY, $Hdf5::H5P_DEFAULT);

  if($self->{_filehandle} < 0) { return 0; }
  return 1;
}

sub is_open {
  my ($self) = @_;

  return ($self->{_filehandle} < 0) ? 0 : 1;
}

Readonly::Scalar my $ROOT => 1;
Readonly::Scalar my $SIZE => 1000;

# Get all group names under the provided path
sub get_groups {
  my ($self, $path) = @_;

  if(!$self->is_open()) { return (); }

  my $group   = Hdf5::H5Gopen1($self->{_filehandle}, $path);
  my $num_obj = [];

  Hdf5::H5Gget_num_objs($group, $num_obj);


  my @object_names;
  for my $n (0..($num_obj->[0] - 1)) {
    my ($str, $type);

    Hdf5::H5Gget_objname_by_idx($group, $n, $str, $SIZE);
    Hdf5::H5Gget_objtype($ROOT, $path . $str, $type);

    if($type eq 'GROUP') {
      $object_names[$n] = $str;
    }
  }

  return @object_names;
}

# Get all dataset names under the provided path
sub get_datasets {
  my ($self, $path) = @_;

  if(!$self->is_open()) { return (); }

  my $group   = Hdf5::H5Gopen1($self->{_filehandle}, $path);
  my $num_obj = [];

  Hdf5::H5Gget_num_objs($group, $num_obj);

  my @object_names;
  for my $n (0..($num_obj->[0] - 1)) {
    my ($str, $type);

    Hdf5::H5Gget_objname_by_idx($group, $n, $str, $SIZE);
    Hdf5::H5Gget_objtype($ROOT, $path . $str, $type);

    if($type eq 'DATASET') {
      $object_names[$n] = $str;
    }
  }

  return @object_names;
}

# Get all attribute names under the provided path
sub get_group_attributes {
  my ($self, $path) = @_;

  if(!$self->is_open()) { return (); }

  my $group      = Hdf5::H5Gopen1($self->{_filehandle}, $path);
  my $attr_count = Hdf5::H5Aget_num_attrs($group);

  my @attribute_names;
  for my $n (0..$attr_count-1) {
    my $attr_id = Hdf5::H5Aopen_idx($group, $n);
    my $name;

    Hdf5::H5Aget_name($attr_id, $SIZE, $name);
    $attribute_names[$n] = $name;
  }

  return @attribute_names;
}

# Get all attribute names under the provided path
sub get_dataset_attributes {
  my ($self, $path) = @_;

  if(!$self->is_open()) { return (); }

  my $dataset    = Hdf5::H5Dopen2($self->{_filehandle}, $path, $Hdf5::H5P_DEFAULT);
  my $attr_count = Hdf5::H5Aget_num_attrs($dataset);

  my @attribute_names;
  for my $n (0..$attr_count-1) {
    my $attr_id = Hdf5::H5Aopen_idx($dataset, $n);
    my $name;

    Hdf5::H5Aget_name($attr_id, $SIZE, $name);
    $attribute_names[$n] = $name;
  }

  return @attribute_names;
}

# return the size of a dataset (given the path)
sub get_dataset_size {
  my ($self, $path) = @_;

  if(!$self->is_open()) { return 0; }

  my $dataset        = Hdf5::H5Dopen2($self->{_filehandle}, $path, $Hdf5::H5P_DEFAULT);
  my $datatype       = Hdf5::H5Dget_type($dataset);
  my $file_dataspace = Hdf5::H5Dget_space($dataset);
  my $dataset_size   = Hdf5::H5Sget_simple_extent_npoints($file_dataspace);

  return $dataset_size;
}

# read the dataset and return it as an array, optionally give a start and end position within the dataset.
sub read_dataset {
  my ($self, $path, $start, $end) = @_;

  if(!$self->is_open()) { return 0; }

  my $dataset  = Hdf5::H5Dopen2($self->{_filehandle}, $path, $Hdf5::H5P_DEFAULT);
  my $datatype = Hdf5::H5Dget_type($dataset);
  my $class;

  Hdf5::H5Tget_class($datatype, $class);
  my $size = Hdf5::H5Tget_size($datatype);

  Hdf5::H5Dclose($dataset);
  Hdf5::H5Tclose($datatype);

  # Processing for compound datatypes is different than everything else.
  if( $class eq 'COMPOUND') {
    return $self->read_dataset_compound($path, $start, $end);
  }

  # Processing simple datatypes
  return $self->read_dataset_simple($path, $start, $end);
}

sub read_dataset_simple {
  my ($self, $path, $start, $end) = @_;

  if(!$self->is_open()) { return 0; }

  my $dataset   = Hdf5::H5Dopen2($self->{_filehandle}, $path, $Hdf5::H5P_DEFAULT);
  my $datatype  = Hdf5::H5Dget_type($dataset);
  my $class;

  Hdf5::H5Tget_class($datatype,$class);
  my $size = Hdf5::H5Tget_size($datatype);

  # change this so, a) they are read as arguments, and b) they can be set to -1 to read everything.

  my @file_hcount   = ( $end - $start );
  my @file_hnstart  = ( $start );
  my @file_hnstride = ( 1 );
  my @file_hblock   = ( 1 );

  my @mem_hcount   = ( $end - $start );
  my @mem_hnstart  = ( 0 );
  my @mem_hnstride = ( 1 );
  my @mem_hblock   = ( 1 );

  my $memtype = $datatype;
  my $dataout;

  # Select part of the dataset to read
  if($start != $START_ALL) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($file_dataspace, $Hdf5::H5S_SELECT_SET, \@file_hnstart, \@file_hnstride, \@file_hcount, \@file_hblock);

    my $memory_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($memory_dataspace, $Hdf5::H5S_SELECT_SET, \@mem_hnstart, \@mem_hnstride, \@mem_hcount, \@mem_hblock);

    Hdf5::H5DreadRaw($dataset, $memtype, $memory_dataspace, $file_dataspace, $Hdf5::H5P_DEFAULT, $dataout, ($end - $start)*$size);
  }

  # Read complete dataset
  if($start == $START_ALL) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    my $dataset_size   = Hdf5::H5Sget_simple_extent_npoints($file_dataspace)*$size;

    Hdf5::H5DreadRaw($dataset, $memtype, $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $dataout, $dataset_size);
  }

  my $is_string;

  my $unpack_string = q[(];
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_C_S1      ())) { $unpack_string .= 'Z'; $is_string = 1; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= 'i'; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= 'I'; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= 's'; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= 'S'; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= 'f'; }
  if(Hdf5::H5Tequal($datatype, Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= 'd'; }
  $unpack_string .= q[)*];

  my @as_array = unpack $unpack_string, $dataout;

  if($is_string) {
    return join q[], @as_array;
  }

  return @as_array;
}

sub read_dataset_compound {
  my ($self, $path, $start, $end) = @_;

  if(!$self->is_open()) { return 0; }

  my $dataset   = Hdf5::H5Dopen2($self->{_filehandle}, $path, $Hdf5::H5P_DEFAULT);
  my $datatype  = Hdf5::H5Dget_type($dataset);
  my $class;

  Hdf5::H5Tget_class($datatype, $class);
  my $size = Hdf5::H5Tget_size($datatype);

  my @names;
  my @classes;
  my @types;
  my @sizes;
  my $total_size = 0;

  my $member_count = Hdf5::H5Tget_nmembers($datatype);

  for my $n (0..$member_count-1) {
    my $name;

    Hdf5::H5Tget_member_name ($datatype, $n, $name );
    Hdf5::H5Tget_member_class($datatype, $n, $class);

    my $type  = Hdf5::H5Tget_member_type($datatype, $n);
    my $size2 = Hdf5::H5Tget_size($type);

    $names  [$n] = $name;
    $classes[$n] = $class;
    $sizes  [$n] = $size2;
    $types  [$n] = $type;
    $total_size += $size;
  }

  my $memtype = Hdf5::H5Tcreate(Hdf5::get_H5T_COMPOUND(), $total_size);

  # Build in memory representation
  my $position=0;
  for my $n (0..$member_count-1) {
    Hdf5::H5Tinsert($memtype,$names[$n],$position,$types[$n]);
    $position += $sizes[$n];
  }

  # change this so, a) they are read as arguments, and b) they can be set to -1 to read everything.

  my @file_hcount   = ( $end - $start );
  my @file_hnstart  = ( $start );
  my @file_hnstride = ( 1 );
  my @file_hblock   = ( 1 );

  my @mem_hcount   = ( $end - $start );
  my @mem_hnstart  = ( 0 );
  my @mem_hnstride = ( 1 );
  my @mem_hblock   = ( 1 );

  my $dataout;

  # Select part of the dataset to read
  if($start != $START_ALL) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($file_dataspace, $Hdf5::H5S_SELECT_SET, \@file_hnstart, \@file_hnstride, \@file_hcount, \@file_hblock);

    my $memory_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($memory_dataspace, $Hdf5::H5S_SELECT_SET, \@mem_hnstart, \@mem_hnstride, \@mem_hcount, \@mem_hblock);

    my $status = Hdf5::H5DreadRaw($dataset, $memtype, $memory_dataspace, $file_dataspace, $Hdf5::H5P_DEFAULT, $dataout, ($end - $start)*$total_size);
  }

  # Read complete dataset
  if($start == $START_ALL) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    my $dataset_size   = Hdf5::H5Sget_simple_extent_npoints($file_dataspace)*$total_size;
    my $status         = Hdf5::H5DreadRaw($dataset, $memtype, $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $dataout, $dataset_size);
  }

  my $unpack_string = q[(];
  for my $n (0..$member_count-1) {
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= 'i'; }
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= 'I'; }
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= 's'; }
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= 'S'; }
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= 'f'; }
    if(Hdf5::H5Tequal($types[$n], Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= 'd'; }
  }
  $unpack_string .= q[)*];

  my @as_array = unpack $unpack_string, $dataout;

  my %result_data;
  for my $n (0..scalar @names-1) {
    my $slice = Hdf5::get_every_nth(\@as_array, scalar @names ,$n);
    $result_data{$names[$n]} = $slice;
  }

  return %result_data;
}

# read a whole attribute
sub read_attribute {
  my ($self, $path, $attribute_name) = @_;

  if(!$self->is_open()) { return 0; }

  my $group       = Hdf5::H5Gopen1($self->{_filehandle}, $path);
  my $attribute   = Hdf5::H5Aopen_name($group, $attribute_name);
  my $memdatatype = Hdf5::H5Aget_type($attribute);
  my $dataout;

  Hdf5::H5AreadRaw($attribute, $memdatatype, $dataout);

  my $is_string;

  my $unpack_string = q[(];
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_C_S1      ())) { $unpack_string .= 'Z'; $is_string=1; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= 'i'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= 'I'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= 's'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= 'S'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_U64LE ())) { $unpack_string .= 'Q'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_STD_I64LE ())) { $unpack_string .= 'q'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= 'f'; }
  if(Hdf5::H5Tequal($memdatatype, Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= 'd'; }
  $unpack_string .= q[)*];

  my @as_array = unpack $unpack_string, $dataout;


  Hdf5::H5Aclose($attribute);
  Hdf5::H5Gclose($group);

  if($is_string) {
    return join q[], @as_array;
  }

  return @as_array;
}

1;
__END__

=head1 NAME

Hdf5::File - A HDF5 reader

=head1 VERSION

$LastChangedRevision$

=head1 SYNOPSIS

=head1 DESCRIPTION

See example_hdf5file.pl for an example, this will iterate over an HDF5 and dump the data much like hdf5dump.

=head1 SUBROUTINES/METHODS

=head2 new

=head2 open

=head2 is_open

=head2 get_groups

=head2 get_datasets

=head2 get_group_attributes

=head2 get_dataset_attributes

=head2 get_dataset_size

=head2 read_dataset

=head2 read_dataset_simple

=head2 read_dataset_compound

=head2 read_attribute

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Hdf5

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author: Roger Pettett$

=head1 LICENSE AND COPYRIGHT

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
